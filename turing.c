#include "turing.h"


int main(int argc, char **argv)
{
	if (argc < 3) 
	{
        	printf("Usage: %s argument1 argument2\n", argv[0]);
        	return -1;
    	}
	TuringMachine *machine = load_machine(argv[1]);
	if machine == NULL
		return -1;
	useTape(machine, argv[2]);
}

State returnActualTransition(char *initial)
{
	int i = 0;

	while states
}

char* useTape(char *tape)
{

}
