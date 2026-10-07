#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"
#include "turing.h"

/*
 * ============================================================
 * OUTILS DE PARSING
 * ============================================================
 */

/*
 * Ignore les espaces, tabulations et retours à la ligne.
 */
static void skip_spaces(const char **p)
{
    while (**p == ' ' ||
           **p == '\t' ||
           **p == '\n' ||
           **p == '\r')
    {
        (*p)++;
    }
}

/*
 * Lit une string JSON :
 *
 * "hello"
 *
 * et retourne "hello".
 */
static char *parse_string(const char **p)
{
    const char *start;
    const char *end;
    char *result;
    size_t len;

    skip_spaces(p);

    if (**p != '"')
        return NULL;

    (*p)++;

    start = *p;

    /*
     * Pour notre JSON, on n'a pas besoin de gérer
     * les caractères échappés.
     */
    end = strchr(start, '"');

    if (end == NULL)
        return NULL;

    len = (size_t)(end - start);

    result = malloc(len + 1);

    if (result == NULL)
        return NULL;

    memcpy(result, start, len);
    result[len] = '\0';

    *p = end + 1;

    return result;
}

/*
 * Cherche une clé :
 *
 * "name"
 *
 * puis se positionne après le ':'.
 */
static int find_key(const char **p, const char *key)
{
    char *found;
    char pattern[256];

    snprintf(pattern, sizeof(pattern), "\"%s\"", key);

    found = strstr(*p, pattern);

    if (found == NULL)
        return 0;

    *p = found + strlen(pattern);

    skip_spaces(p);

    if (**p != ':')
        return 0;

    (*p)++;

    skip_spaces(p);

    return 1;
}

/*
 * ============================================================
 * LECTURE DU FICHIER
 * ============================================================
 */

static char *read_file(const char *filename)
{
    FILE *file;
    long size;
    char *buffer;

    file = fopen(filename, "r");

    if (file == NULL)
        return NULL;

    if (fseek(file, 0, SEEK_END) != 0)
    {
        fclose(file);
        return NULL;
    }

    size = ftell(file);

    if (size < 0)
    {
        fclose(file);
        return NULL;
    }

    rewind(file);

    buffer = malloc((size_t)size + 1);

    if (buffer == NULL)
    {
        fclose(file);
        return NULL;
    }

    if (fread(buffer, 1, (size_t)size, file)
        != (size_t)size)
    {
        free(buffer);
        fclose(file);
        return NULL;
    }

    buffer[size] = '\0';

    fclose(file);

    return buffer;
}

/*
 * ============================================================
 * ALPHABET
 * ============================================================
 *
 * "alphabet": [ "1", ".", "-", "=" ]
 */

static int parse_alphabet(
    const char **p,
    TuringMachine *machine)
{
    char *value;
    int capacity;
    int size;

    skip_spaces(p);

    if (**p != '[')
        return 0;

    (*p)++;

    capacity = 4;
    size = 0;

    machine->alphabet =
        malloc((size_t)capacity * sizeof(char));

    if (machine->alphabet == NULL)
        return 0;

    while (1)
    {
        skip_spaces(p);

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        value = parse_string(p);

        if (value == NULL || value[0] == '\0')
        {
            free(value);
            return 0;
        }

        if (size >= capacity)
        {
            char *tmp;

            capacity *= 2;

            tmp = realloc(
                machine->alphabet,
                (size_t)capacity * sizeof(char)
            );

            if (tmp == NULL)
            {
                free(value);
                return 0;
            }

            machine->alphabet = tmp;
        }

        machine->alphabet[size] = value[0];
        size++;

        free(value);

        skip_spaces(p);

        if (**p == ',')
        {
            (*p)++;
            continue;
        }

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        return 0;
    }

    machine->alphabet_size = size;

    return 1;
}

/*
 * ============================================================
 * STATES
 * ============================================================
 *
 * "states": [ "scanright", "eraseone", ... ]
 */

static int parse_states(
    const char **p,
    TuringMachine *machine)
{
    char *value;
    int capacity;
    int size;

    skip_spaces(p);

    if (**p != '[')
        return 0;

    (*p)++;

    capacity = 4;
    size = 0;

    machine->states =
        malloc(
            (size_t)capacity * sizeof(State)
        );

    if (machine->states == NULL)
        return 0;

    while (1)
    {
        skip_spaces(p);

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        value = parse_string(p);

        if (value == NULL)
            return 0;

        if (size >= capacity)
        {
            State *tmp;

            capacity *= 2;

            tmp = realloc(
                machine->states,
                (size_t)capacity * sizeof(State)
            );

            if (tmp == NULL)
            {
                free(value);
                return 0;
            }

            machine->states = tmp;
        }

        machine->states[size].name = value;
        machine->states[size].transitions = NULL;
        machine->states[size].nb_transitions = 0;

        size++;

        skip_spaces(p);

        if (**p == ',')
        {
            (*p)++;
            continue;
        }

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        return 0;
    }

    machine->nb_states = size;

    return 1;
}

/*
 * ============================================================
 * FINALS
 * ============================================================
 *
 * "finals": [ "HALT" ]
 */

static int parse_finals(
    const char **p,
    TuringMachine *machine)
{
    char *value;
    int capacity;
    int size;

    skip_spaces(p);

    if (**p != '[')
        return 0;

    (*p)++;

    capacity = 2;
    size = 0;

    machine->finals =
        malloc(
            (size_t)capacity * sizeof(char *)
        );

    if (machine->finals == NULL)
        return 0;

    while (1)
    {
        skip_spaces(p);

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        value = parse_string(p);

        if (value == NULL)
            return 0;

        if (size >= capacity)
        {
            char **tmp;

            capacity *= 2;

            tmp = realloc(
                machine->finals,
                (size_t)capacity * sizeof(char *)
            );

            if (tmp == NULL)
            {
                free(value);
                return 0;
            }

            machine->finals = tmp;
        }

        machine->finals[size] = value;
        size++;

        skip_spaces(p);

        if (**p == ',')
        {
            (*p)++;
            continue;
        }

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        return 0;
    }

    machine->nb_finals = size;

    return 1;
}

/*
 * ============================================================
 * ACTION
 * ============================================================
 */

static int parse_action(
    const char *value,
    Action *action)
{
    if (strcmp(value, "RIGHT") == 0)
    {
        *action = RIGHT;
        return 1;
    }

    if (strcmp(value, "LEFT") == 0)
    {
        *action = LEFT;
        return 1;
    }

    return 0;
}

/*
 * ============================================================
 * UNE TRANSITION
 * ============================================================
 *
 * {
 *     "read": "1",
 *     "write": "=",
 *     "action": "LEFT",
 *     "to_state": "subone"
 * }
 */

static int parse_transition(
    const char **p,
    Transition *transition)
{
    char *value;

    skip_spaces(p);

    if (**p != '{')
        return 0;

    (*p)++;

    /*
     * read
     */
    if (!find_key(p, "read"))
        return 0;

    value = parse_string(p);

    if (value == NULL)
        return 0;

    transition->read = value[0];

    free(value);

    /*
     * write
     */
    if (!find_key(p, "write"))
        return 0;

    value = parse_string(p);

    if (value == NULL)
        return 0;

    transition->write = value[0];

    free(value);

    /*
     * action
     */
    if (!find_key(p, "action"))
        return 0;

    value = parse_string(p);

    if (value == NULL)
        return 0;

    if (!parse_action(value, &transition->action))
    {
        free(value);
        return 0;
    }

    free(value);

    /*
     * to_state
     */
    if (!find_key(p, "to_state"))
        return 0;

    value = parse_string(p);

    if (value == NULL)
        return 0;

    transition->to_state = value;

    /*
     * fin de l'objet
     */
    skip_spaces(p);

    if (**p != '}')
        return 0;

    (*p)++;

    return 1;
}

/*
 * ============================================================
 * TRANSITIONS D'UN ETAT
 * ============================================================
 */

static int parse_state_transitions(
    const char **p,
    State *state)
{
    int capacity;
    int size;

    skip_spaces(p);

    if (**p != '[')
        return 0;

    (*p)++;

    capacity = 4;
    size = 0;

    state->transitions =
        malloc(
            (size_t)capacity * sizeof(Transition)
        );

    if (state->transitions == NULL)
        return 0;

    while (1)
    {
        skip_spaces(p);

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        if (size >= capacity)
        {
            Transition *tmp;

            capacity *= 2;

            tmp = realloc(
                state->transitions,
                (size_t)capacity *
                sizeof(Transition)
            );

            if (tmp == NULL)
                return 0;

            state->transitions = tmp;
        }

        if (!parse_transition(
                p,
                &state->transitions[size]))
        {
            return 0;
        }

        size++;

        skip_spaces(p);

        if (**p == ',')
        {
            (*p)++;
            continue;
        }

        if (**p == ']')
        {
            (*p)++;
            break;
        }

        return 0;
    }

    state->nb_transitions = size;

    return 1;
}

/*
 * ============================================================
 * TRANSITIONS
 * ============================================================
 *
 * "transitions": {
 *
 *     "scanright": [
 *         ...
 *     ],
 *
 *     "eraseone": [
 *         ...
 *     ]
 *
 * }
 */

static int parse_transitions(
    const char **p,
    TuringMachine *machine)
{
    char *state_name;
    int i;

    skip_spaces(p);

    if (**p != '{')
        return 0;

    (*p)++;

    while (1)
    {
        skip_spaces(p);

        if (**p == '}')
        {
            (*p)++;
            break;
        }

        state_name = parse_string(p);

        if (state_name == NULL)
            return 0;

        skip_spaces(p);

        if (**p != ':')
        {
            free(state_name);
            return 0;
        }

        (*p)++;

        /*
         * Cherche l'état correspondant.
         */
        for (i = 0; i < machine->nb_states; i++)
        {
            if (strcmp(
                    machine->states[i].name,
                    state_name) == 0)
            {
                break;
            }
        }

        if (i == machine->nb_states)
        {
            free(state_name);
            return 0;
        }

        if (!parse_state_transitions(
                p,
                &machine->states[i]))
        {
            free(state_name);
            return 0;
        }

        free(state_name);

        skip_spaces(p);

        if (**p == ',')
        {
            (*p)++;
            continue;
        }

        if (**p == '}')
        {
            (*p)++;
            break;
        }

        return 0;
    }

    return 1;
}

/*
 * ============================================================
 * LOAD MACHINE
 * ============================================================
 */

TuringMachine *load_machine(const char *filename)
{
    char *content;
    const char *p;
    TuringMachine *machine;

    content = read_file(filename);

    if (content == NULL)
    {
        fprintf(
            stderr,
            "Impossible d'ouvrir %s\n",
            filename
        );

        return NULL;
    }

    machine = calloc(
        1,
        sizeof(TuringMachine)
    );

    if (machine == NULL)
    {
        free(content);
        return NULL;
    }

    p = content;

    /*
     * name
     */
    if (!find_key(&p, "name"))
        goto error;

    machine->name = parse_string(&p);

    if (machine->name == NULL)
        goto error;

    /*
     * alphabet
     */
    if (!find_key(&p, "alphabet"))
        goto error;

    if (!parse_alphabet(&p, machine))
        goto error;

    /*
     * blank
     */
    if (!find_key(&p, "blank"))
        goto error;

    machine->blank = '\0';

    {
        char *value = parse_string(&p);

        if (value == NULL)
            goto error;

        machine->blank = value[0];

        free(value);
    }

    /*
     * states
     */
    if (!find_key(&p, "states"))
        goto error;

    if (!parse_states(&p, machine))
        goto error;

    /*
     * initial
     */
    if (!find_key(&p, "initial"))
        goto error;

    machine->initial = parse_string(&p);

    if (machine->initial == NULL)
        goto error;

    /*
     * finals
     */
    if (!find_key(&p, "finals"))
        goto error;

    if (!parse_finals(&p, machine))
        goto error;

    /*
     * transitions
     */
    if (!find_key(&p, "transitions"))
        goto error;

    if (!parse_transitions(&p, machine))
        goto error;

    free(content);

    return machine;

error:
    fprintf(stderr, "JSON invalide ou format inattendu\n");

    free(content);
    free_machine(machine);

    return NULL;
}

/*
 * ============================================================
 * AFFICHAGE
 * ============================================================
 */

void print_machine(const TuringMachine *machine)
{
    int i;
    int j;

    if (machine == NULL)
    {
        printf("Machine NULL\n");
        return;
    }

    printf("\n");
    printf("========================================\n");
    printf("        TURING MACHINE\n");
    printf("========================================\n");

    printf("Name    : %s\n", machine->name);

    printf("Blank   : '%c'\n", machine->blank);

    printf("Alphabet: ");

    for (i = 0; i < machine->alphabet_size; i++)
    {
        printf("'%c'", machine->alphabet[i]);

        if (i + 1 < machine->alphabet_size)
            printf(", ");
    }

    printf("\n");

    printf("Initial : %s\n", machine->initial);

    printf("Finals  : ");

    for (i = 0; i < machine->nb_finals; i++)
    {
        printf("%s", machine->finals[i]);

        if (i + 1 < machine->nb_finals)
            printf(", ");
    }

    printf("\n");

    printf("\nStates (%d):\n", machine->nb_states);

    for (i = 0; i < machine->nb_states; i++)
    {
        State *state = &machine->states[i];

        printf("\n  State: %s\n", state->name);

        if (state->nb_transitions == 0)
        {
            printf("    No transitions\n");
            continue;
        }

        printf(
            "    Transitions (%d):\n",
            state->nb_transitions
        );

        for (j = 0; j < state->nb_transitions; j++)
        {
            Transition *transition =
                &state->transitions[j];

            printf(
                "      read='%c'  "
                "write='%c'  "
                "action=%s  "
                "to_state=%s\n",
                transition->read,
                transition->write,
                transition->action == RIGHT
                    ? "RIGHT"
                    : "LEFT",
                transition->to_state
            );
        }
    }

    printf("\n========================================\n\n");
}

/*
 * ============================================================
 * FREE MACHINE
 * ============================================================
 */

void free_machine(TuringMachine *machine)
{
    int i;
    int j;

    if (machine == NULL)
        return;

    free(machine->name);
    free(machine->alphabet);
    free(machine->initial);

    /*
     * Final states
     */
    for (i = 0; i < machine->nb_finals; i++)
        free(machine->finals[i]);

    free(machine->finals);

    /*
     * States
     */
    for (i = 0; i < machine->nb_states; i++)
    {
        State *state = &machine->states[i];

        free(state->name);

        for (j = 0; j < state->nb_transitions; j++)
            free(state->transitions[j].to_state);

        free(state->transitions);
    }

    free(machine->states);

    free(machine);
}
