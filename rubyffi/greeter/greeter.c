#include <stdio.h>

struct person {
	char *name;
	unsigned age;
};

void greet(struct person *person) {
	printf("Hello, %s (aged %d)\n", person->name, person->age);
}
