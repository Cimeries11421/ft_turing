#ifndef TURING_MACHINE_H
#define TURING_MACHINE_H

typedef enum {
    RIGHT,
    LEFT
} Action;

typedef struct {
    char read;
    char write;
    Action action;
    char *to_state;
} Transition;

typedef struct {
    char *name;
    Transition *transitions;
    int nb_transitions;
} State;

typedef struct {
    char *name;

    char *alphabet;
    int alphabet_size;

    char blank;

    State *states;
    int nb_states;

    char *initial;

    char **finals;
    int nb_finals;
} TuringMachine;

#endif
