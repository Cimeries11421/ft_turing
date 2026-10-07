
#ifndef PARSER_H
#define PARSER_H

#include "turing.h"

TuringMachine *load_machine(const char *filename);
void print_machine(const TuringMachine *machine);
void free_machine(TuringMachine *machine);

#endif
