type action_type = LEFT | RIGHT

type transition =
{
    read       : char;
    write      : char;
    action     : action_type;
    toState    : string;

}

type state = 
{
    name          : string;
    transitions   : transition list;
}

type turingMachine =
{
    name         : string;
    alphabet     : char list;
    blank        : char;
    states       : state list;
    initial      : string;
    finals       : string list;
}
