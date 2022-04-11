#include "token.h"
#include "shared.h"

#include <ctype.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

tokenizer new_tokenizer(const char *stream) {
	return (tokenizer) {
		.stream = stream,
		.lineno = 1
	};
}

#define parse_error(tzr, msg, ...) (die(\
	"invalid syntax at %d: " msg, tzr->lineno, __VA_ARGS__))

static char peek(tokenizer *tzr) {
	return tzr->stream[0];
}

static void advance(tokenizer *tzr) {
	if (*tzr->stream++ == '\n')
		++tzr->lineno;
}

static token parse_integer(tokenizer *tzr, bool is_negative) {
	token tkn = { .kind = TK_LITERAL };
	long long num = 0;

	char c;
	while (isdigit(c = peek(tzr))) {
		num *= 10;
		num += c - '0';
		advance(tzr);
	}

	if (isalpha(c) || c == '_')
		parse_error(tzr, "bad character '%c' after integer literal", c);

	if (is_negative)
		num *= -1;

	tkn.v = num2value(num);
	return tkn;
}

static token parse_identifier(tokenizer *tzr) {
	const char *start = tzr->stream;

	char c;
	while(isalnum(c = peek(tzr)) || c == '_')
		advance(tzr);
	int len = tzr->stream - start;

	token tkn;


	if (!strncmp(start, "true", len)) return tkn.kind = TK_LITERAL, tkn.v = VTRUE, tkn;
	if (!strncmp(start, "false", len)) return tkn.kind = TK_LITERAL, tkn.v = VFALSE, tkn;
	if (!strncmp(start, "null", len)) return tkn.kind = TK_LITERAL, tkn.v = VNULL, tkn;
	#define CHECK_FOR_KEYWORD(str_, kind_) \
		if (!strncmp(start, str_, strlen(str_))) return tkn.kind = kind_, tkn;
	CHECK_FOR_KEYWORD("global", TK_GLOBAL)
	CHECK_FOR_KEYWORD("function", TK_FUNCTION)
	CHECK_FOR_KEYWORD("if", TK_IF)
	CHECK_FOR_KEYWORD("else", TK_ELSE)
	CHECK_FOR_KEYWORD("while", TK_WHILE)
	CHECK_FOR_KEYWORD("break", TK_BREAK)
	CHECK_FOR_KEYWORD("continue", TK_CONTINUE)
	CHECK_FOR_KEYWORD("return", TK_RETURN)

	tkn.kind = TK_IDENT;
	tkn.str = strndup(start, tzr->stream - start); // we own the ident

	return tkn;
}

static int parse_hex(tokenizer *tzr, char c) {
	if (isdigit(c)) return c - '0';
	if ('a' <= c && c <= 'f') return c - 'a' + 10;
	if ('A' <= c && c <= 'F') return c - 'F' + 10;
	parse_error(tzr, "unknown hex digit '%c'", c);
}

static token parse_string(tokenizer *tzr) {
	char quote = peek(tzr);
	advance(tzr);

	const char *start = tzr->stream;
	int starting_line = tzr->lineno;
	bool was_anything_escaped = false;

	char c;
	while ((c = peek(tzr)) != quote) {
		if (c == '\0')
			parse_error(tzr, "unterminated quote encountered started on %d", starting_line);

		advance(tzr);

		if (c == '\\')  {
			c = peek(tzr);

			if (quote == '\"' || (c == '\\' || c == '\'' || c == '\"'))
				was_anything_escaped = true;
		}
	}

	int length = tzr->stream - start;
	token tkn = { .kind = TK_LITERAL };
	advance(tzr);

	// simple case, just return the original string.
	if (!was_anything_escaped)
		return tkn.v = str2value(strndup(start, length)), tkn;

	// well, something was escaped, so we now need to deal with that.
	char *str = malloc(length); // note not `+1`, as we're removing at least 1 slash.
	int i = 0, stridx = 0;

	while (i < length) {
		if (start[i++] != '\\') {
			str[stridx++] = start[i];
			continue;
		}

		char c = start[i++];

		if (quote == '\'') {
			if (c != '\\' && c != '\"' && c != '\'')
				str[stridx++] = '\\';
		} else {
			switch (c) {
			case '\'': case '\"': case '\\': break;

			case 'n': c = '\n'; break;
			case 't': c = '\t'; break;
			case 'r': c = '\r'; break;
			case 'f': c = '\f'; break;
			case '0': c = '\0'; break;
			case 'x':
				c = (parse_hex(tzr, start[i]) << 4) + parse_hex(tzr, start[i+1]);
				i += 2;
				break;
			default:
				parse_error(tzr, "unknown escape character '%c'", c);
			}
		}

		str[stridx++] = c;
	}

	str[stridx] = '\0';
	tkn.v = str2value(str);
	return tkn;
}

token next_token(tokenizer *tzr) {
	char c;

	// Strip whitespace and comments.
	for (; (c = peek(tzr)); advance(tzr)) {
		if (c == '#')
			do {
				advance(tzr);
			} while ((c = peek(tzr)) && c != '\n');

		if (!isspace(c))
			break;
	}

	// For simple tokens, just return them.
	switch (c) {
	case '=': case '!': case '<': case '>':
		if (tzr->stream[1] == '=')
			tzr->stream++, c += 0x80;
		goto normal;

	case '+': case '-': 
		if (isdigit(tzr->stream[1]))
			return advance(tzr), parse_integer(tzr, c == '-');
		// fallthru

	case '(': case ')': case '[': case ']': case '{': case '}':
	case ',': case ';': case '*': case '/': case '%':
	normal:
		advance(tzr);
		// fallthru

	case '\0':
		return (token) { .kind = c };
	}

	// for more complicated ones, defer to their functions.
	if (isdigit(c)) return parse_integer(tzr, false);
	if (isalpha(c) || c == '_') return parse_identifier(tzr);
	if (c == '\'' || c == '\"') return parse_string(tzr);

	parse_error(tzr, "unknown token start: '%c'", c);
}


void dump_token(FILE *out, token tkn) {
	switch(tkn.kind) {
	case TK_EOF: fprintf(out, "EOF\n"); break;
	case TK_LITERAL: dump_value(out, tkn.v); break;
	case TK_IDENT: fprintf(out, "Ident(%s)\n", tkn.str); break;
	case TK_GLOBAL: fprintf(out, "Token(global)\n"); break;
	case TK_FUNCTION: fprintf(out, "Token(function)\n"); break;
	case TK_IF: fprintf(out, "Token(if)\n"); break;
	case TK_ELSE: fprintf(out, "Token(else)\n"); break;
	case TK_WHILE: fprintf(out, "Token(while)\n"); break;
	case TK_BREAK: fprintf(out, "Token(break)\n"); break;
	case TK_CONTINUE: fprintf(out, "Token(continue)\n"); break;
	case TK_RETURN: fprintf(out, "Token(return)\n"); break;
	case TK_LPAREN: fprintf(out, "Token[(]\n"); break;
	case TK_RPAREN: fprintf(out, "Token[)]\n"); break;
	case TK_LBRACKET: fprintf(out, "Token([)\n"); break;
	case TK_RBRACKET: fprintf(out, "Token(])\n"); break;
	case TK_LBRACE: fprintf(out, "Token({)\n"); break;
	case TK_RBRACE: fprintf(out, "Token(})\n"); break;
	case TK_ASSIGN: fprintf(out, "Token(=)\n"); break;
	case TK_COMMA: fprintf(out, "Token(,)\n"); break;
	case TK_SEMICOLON: fprintf(out, "Token(;)\n"); break;
	case TK_ADD: fprintf(out, "Token(+)\n"); break;
	case TK_SUB: fprintf(out, "Token(-)\n"); break;
	case TK_MUL: fprintf(out, "Token(*)\n"); break;
	case TK_DIV: fprintf(out, "Token(/)\n"); break;
	case TK_MOD: fprintf(out, "Token(%%)\n"); break;
	case TK_NOT: fprintf(out, "Token(!)\n"); break;
	case TK_LTH: fprintf(out, "Token(<)\n"); break;
	case TK_GTH: fprintf(out, "Token(>)\n"); break;
	case TK_LEQ: fprintf(out, "Token(<=)\n"); break;
	case TK_GEQ: fprintf(out, "Token(>=)\n"); break;
	case TK_EQL: fprintf(out, "Token(==)\n"); break;
	case TK_NEQ: fprintf(out, "Token(!=)\n"); break;
	default: fprintf(out, "Token(<?>)\n"); break;
	}
}
