#define CONCAT(a, b) a ## b
#define CONCAT2(a, b) CONCAT(a, b)

#define MAKE_IDENT(...) MAKE_IDENT_(COUNT(dummy, ##__VA_ARGS__,8,7,6,5,4,3,2,1,0),##__VA_ARGS__)
#define MAKE_IDENT_(n, ...) CONCAT2(DOIT,n)(__VA_ARGS__)
#define COUNT(n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,...) n10

#define DOIT1(x)     x
#define DOIT2(x,...) CONCAT2(x##_,DOIT1(__VA_ARGS__))
#define DOIT3(x,...) CONCAT2(x##_,DOIT2(__VA_ARGS__))
#define DOIT4(x,...) CONCAT2(x##_,DOIT3(__VA_ARGS__))
#define DOIT5(x,...) CONCAT2(x##_,DOIT4(__VA_ARGS__))
#define DOIT6(x,...) CONCAT2(x##_,DOIT5(__VA_ARGS__))

int main() {
	int MAKE_IDENT(a,b,c) = 3;
	printf("%d\n", a_b_c);
}
