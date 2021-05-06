#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <assert.h>

static void LIST_NOFREE(void *t) {}
#define LIST_DEFINE(kind, list_name, free_fn)                                  \
typedef struct list_name {                                                     \
    size_t len, cap;                                                           \
    kind *eles;                                                                \
} list_name;                                                                   \
                                                                               \
list_name *list_name##_alloc(size_t cap) {                                     \
    list_name *list;                                                           \
    if (!(list = malloc(sizeof(list_name)))) abort();                          \
    if (!(list->eles = malloc(sizeof(kind) * cap))) abort();                   \
    list->len = 0;                                                             \
    list->cap = cap;                                                           \
    return list;                                                               \
}                                                                              \
                                                                               \
void list_name##_free(list_name *list) {                                       \
    size_t i;                                                                  \
    for (i = 0; i < list->len; ++i) free_fn(list->eles + i);                   \
    free(list);                                                                \
}                                                                              \
                                                                               \
void list_name##_resize(list_name *list, size_t cap) {                         \
    size_t i;                                                                  \
    if (list->len > cap) {                                                     \
        for (i = cap; i < list->len; ++i) free_fn(list->eles + i);             \
        list->len = cap;                                                       \
    }                                                                          \
    if (!(list->eles = realloc(list->eles, list->cap = cap))) abort();         \
}                                                                              \
                                                                               \
void list_name##_push(list_name *list, kind ele) {                             \
    if (list->len == list->cap) list_name##_resize(list, list->cap * 2);       \
    list->eles[list->len++] = ele;                                             \
}                                                                              \
                                                                               \
kind list_name##_pop(list_name *list) {                                        \
    assert(list->len);                                                         \
    return list->eles[--list->len];                                            \
}                                                                              \
                                                                               \
void list_name##_insert(list_name *list, size_t idx, kind ele)  {              \
    assert(idx <= list->len);                                                  \
    if (idx == list->len) { list_name##_push(list, ele); return; }             \
    if (list->len == list->cap) list_name##_resize(list, list->cap * 2);       \
    memmove(list->eles + idx+1, list->eles + idx, sizeof(kind[list->len++]));  \
    list->eles[idx] = ele;                                                     \
}                                                                              \
                                                                               \
kind list_name##_delete(list_name *list, size_t idx) {                         \
    kind result, *ptr;                                                         \
    assert(idx < list->len);                                                   \
    if (idx == list->len) return list_name##_pop(list);                        \
    result = list->eles[idx]; ptr=list->eles + idx;                            \
    memmove(ptr, ptr + 1, sizeof(kind [list->len--]));                         \
    return result;                                                             \
}

LIST_DEFINE(int, int_list, LIST_NOFREE);

#include <stdio.h>

int main () {
    size_t i;
    struct int_list *list;

    list = int_list_alloc(4);

    int_list_push(list, 1);
    int_list_push(list, 3);
    int_list_push(list, 9);
    int_list_push(list, 4);
    int_list_insert(list, 1, 2);
    int_list_delete(list, 3);

    for (i = 0; i < list->len; ++i) printf("%d ", list->eles[i]);
    putchar('\n');
}