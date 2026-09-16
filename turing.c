#include "turing.h"
#include "parser.h"
#include <unistd.h>
#include <string.h>
#include <stdio.h>

Transition *returnActualTransition(TuringMachine *machine, char *initial, char input_c);
void useTape(TuringMachine *machine, char *input);

int main(int argc, char **argv)
{
	if (argc < 3) 
	{
        	printf("Usage: %s argument1 argument2\n", argv[0]);
        	return -1;
    }
	TuringMachine *machine = load_machine(argv[1]);
	/*if machine == NULL
		return -1;*/
	print_machine(machine);
	write(1, "BONJOUR", 7);
	printf("argv[0] = %s\n", argv[0]);
	printf("argv[1] = %s\n", argv[1]);
	printf("argv[2] = %s\n", argv[2]);
	printf("Old tape : %s\n", argv[2]);
	useTape(machine, argv[2]);
	//free_machine(machine);
}

Transition *returnActualTransition(TuringMachine *machine, char *initial, char input_c)
{
	int i = 0;
	int y = 0;

	
	while (i < machine->nb_states) 	
	{ 
		if (strcmp(machine->states[i].name, initial) == 0)
			break;
	 	i++; 
	}
	if (i == machine->nb_states) 
		return NULL;
		
	while (y < machine->states[i].nb_transitions)
	{
		if (machine->states[i].transitions[y].read == input_c) 
			return (&machine->states[i].transitions[y]);
		y++;
	}
	return NULL;
}

void useTape(TuringMachine *machine, char *input)
{
	Transition *transition_tmp;

	int y = 0;
	while (input[y])
	{
		printf("avant ReturnActualTransition\n");
		transition_tmp = returnActualTransition(machine, machine->initial, input[y]);
		printf("apres transition_tmp->write : %c\n", transition_tmp->write);
		input[y] = transition_tmp->write;
		if (transition_tmp->action == RIGHT)
			y++;
		else
			y--;
		machine->initial = transition_tmp->to_state;
		if (strcmp(machine->initial, "HALT") == 0)
			break;
	}
	printf("New tape : %s", input);
}