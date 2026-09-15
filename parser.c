#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cJSON.h"
#include "turing_machine.h"

static char *read_file(const char *filename)
{
    FILE *file = fopen(filename, "r");

    if (file == NULL)
        return NULL;

    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    rewind(file);

    char *buffer = malloc(size + 1);

    if (buffer == NULL) {
        fclose(file);
        return NULL;
    }

    fread(buffer, 1, size, file);
    buffer[size] = '\0';

    fclose(file);

    return buffer;
}

static Action parse_action(const char *action)
{
    if (strcmp(action, "RIGHT") == 0)
        return RIGHT;

    if (strcmp(action, "LEFT") == 0)
        return LEFT;

    fprintf(stderr, "Action inconnue : %s\n", action);
    exit(EXIT_FAILURE);
}

TuringMachine *load_machine(const char *filename)
{
    char *content = read_file(filename);

    if (content == NULL) {
        fprintf(stderr, "Impossible d'ouvrir %s\n", filename);
        return NULL;
    }

    cJSON *json = cJSON_Parse(content);

    if (json == NULL) {
        fprintf(stderr, "JSON invalide\n");
        free(content);
        return NULL;
    }

    TuringMachine *machine = malloc(sizeof(TuringMachine));

    if (machine == NULL) {
        cJSON_Delete(json);
        free(content);
        return NULL;
    }

    /*
     * name
     */
    cJSON *name = cJSON_GetObjectItem(json, "name");

    machine->name = strdup(name->valuestring);


    /*
     * blank
     */
    cJSON *blank = cJSON_GetObjectItem(json, "blank");

    machine->blank = blank->valuestring[0];


    /*
     * alphabet
     */
    cJSON *alphabet = cJSON_GetObjectItem(json, "alphabet");

    machine->alphabet_size = cJSON_GetArraySize(alphabet);

    machine->alphabet =
        malloc(machine->alphabet_size * sizeof(char));

    for (int i = 0; i < machine->alphabet_size; i++) {
        cJSON *symbol = cJSON_GetArrayItem(alphabet, i);

        machine->alphabet[i] = symbol->valuestring[0];
    }


    /*
     * initial
     */
    cJSON *initial = cJSON_GetObjectItem(json, "initial");

    machine->initial = strdup(initial->valuestring);


    /*
     * finals
     */
    cJSON *finals = cJSON_GetObjectItem(json, "finals");

    machine->nb_finals = cJSON_GetArraySize(finals);

    machine->finals =
        malloc(machine->nb_finals * sizeof(char *));

    for (int i = 0; i < machine->nb_finals; i++) {
        cJSON *final = cJSON_GetArrayItem(finals, i);

        machine->finals[i] = strdup(final->valuestring);
    }


    /*
     * states
     */
    cJSON *states = cJSON_GetObjectItem(json, "states");

    machine->nb_states = cJSON_GetArraySize(states);

    machine->states =
        malloc(machine->nb_states * sizeof(State));

    /*
     * transitions
     */
    cJSON *all_transitions =
        cJSON_GetObjectItem(json, "transitions");

    for (int i = 0; i < machine->nb_states; i++) {

        cJSON *state_json =
            cJSON_GetArrayItem(states, i);

        State *state = &machine->states[i];

        state->name =
            strdup(state_json->valuestring);

        cJSON *state_transitions =
            cJSON_GetObjectItem(
                all_transitions,
                state->name
            );

        /*
         * HALT peut ne pas avoir de transitions
         */
        if (state_transitions == NULL) {
            state->transitions = NULL;
            state->nb_transitions = 0;
            continue;
        }

        state->nb_transitions =
            cJSON_GetArraySize(state_transitions);

        state->transitions =
            malloc(
                state->nb_transitions *
                sizeof(Transition)
            );

        for (int j = 0;
             j < state->nb_transitions;
             j++) {

            cJSON *transition_json =
                cJSON_GetArrayItem(
                    state_transitions,
                    j
                );

            Transition *transition =
                &state->transitions[j];

            cJSON *read =
                cJSON_GetObjectItem(
                    transition_json,
                    "read"
                );

            cJSON *write =
                cJSON_GetObjectItem(
                    transition_json,
                    "write"
                );

            cJSON *action =
                cJSON_GetObjectItem(
                    transition_json,
                    "action"
                );

            cJSON *to_state =
                cJSON_GetObjectItem(
                    transition_json,
                    "to_state"
                );

            transition->read =
                read->valuestring[0];

            transition->write =
                write->valuestring[0];

            transition->action =
                parse_action(action->valuestring);

            transition->to_state =
                strdup(to_state->valuestring);
        }
    }

    cJSON_Delete(json);
    free(content);

    return machine;
}
