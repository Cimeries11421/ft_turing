open Turing_types

let unary_sub =
  {
    name = "unary_sub";

    alphabet = [ '1'; '.'; '-'; '=' ];

    blank = '.';

    initial = "scanright";

    finals = [ "HALT" ];

    states =
      [
        {
          name = "scanright";
          transitions =
            [
              { read = '.'; write = '.'; action = RIGHT; toState = "scanright" };
              { read = '1'; write = '1'; action = RIGHT; toState = "scanright" };
              { read = '-'; write = '-'; action = RIGHT; toState = "scanright" };
              { read = '='; write = '.'; action = LEFT; toState = "eraseone" };
            ];
        };

        {
          name = "eraseone";
          transitions =
            [
              { read = '1'; write = '='; action = LEFT; toState = "subone" };
              { read = '-'; write = '.'; action = LEFT; toState = "HALT" };
            ];
        };

        {
          name = "subone";
          transitions =
            [
              { read = '1'; write = '1'; action = LEFT; toState = "subone" };
              { read = '-'; write = '-'; action = LEFT; toState = "skip" };
            ];
        };

        {
          name = "skip";
          transitions =
            [
              { read = '.'; write = '.'; action = LEFT; toState = "skip" };
              { read = '1'; write = '.'; action = RIGHT; toState = "scanright" };
            ];
        };

        {
          name = "HALT";
          transitions = [];
        };
      ];
  }


let even =
  {
    name = "even";

    alphabet = [ '0'; '.'; 'y'; 'n' ];

    blank = '.';

    initial = "odd";

    finals = [ "HALT" ];

    states =
      [
        {
          name = "odd";
          transitions =
            [
              { read = '0'; write = '0'; action = RIGHT; toState = "even" };
              { read = '.'; write = 'y'; action = RIGHT; toState = "HALT" };
            ];
        };

        {
          name = "even";
          transitions =
            [
              { read = '0'; write = '0'; action = RIGHT; toState = "odd" };
              { read = '.'; write = 'n'; action = RIGHT; toState = "HALT" };
            ];
        };

        {
          name = "HALT";
          transitions = [];
        };
      ];
  }
