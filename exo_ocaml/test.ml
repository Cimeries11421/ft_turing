let addition x y =
        x + y

let listNombre = [10; 20; 30; 40; 50]

let premier_element listNombre =
        match listNombre with (*la valeur contenue dans liste et regarde à quoi elle ressemble*)
        | [] -> None
        | x :: y :: reste -> y (*le :: retire le premier element de la liste*)
        | x :: reste -> x (*le :: retire le premier element de la liste*)

let () = 
        print_int(premier_element(listNombre));

