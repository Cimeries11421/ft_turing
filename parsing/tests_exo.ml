let describe_number x =
    match x with
    | 0 -> "zero"
    | 1 -> "one"
    | _ -> "other"

type direction =
    | Left
    | Right

(* type variant avec 3 possibilites *)
type result =  (*type*)
    | Accepted (*constructeur*)
    | Refused
    | Blocked


let rec length list =
    match list with
    | [] -> 0
    | _ :: tail -> 1 + length tail

let r = Accepted

(*Pattern matching*)
let describe r =
    match r with
    | Accepted -> "The Machine accepted"
    | Refused -> "The Machine refused"
    | Blocked -> "The Machine is blocked"

(*Les records*)
type person = {
    name : string;
    age : int;
}

(*Pour creer un objet, ex: *)
let alice = {
    name = "Alice";
    age = 21;
}

(*Pour acceder a un champ : *)
alice.name (*donne*) Alice
alice.age (*donne*) 21


(*EXO*)
type machine = {
    name : string;
    states : string list;
    initial : string;
}

let odds_machine = {
    name = "Machine for odds";
    states = ["scanright"; "eraseone"; "skip"];
    initial = "scanright";
}

let rec find_state etat_list etat_searched =
    match etat_list with
    | [] -> None
    | head :: tail ->
        if head = etat_searched then
            Some head
        else
            find_state tail etat_searched

let rec contains_state abc_list etat_searched =
    match abc_list with
    | [] -> false
    | head :: tail -> 
        if head = etat_searched then
            true
        else
            contains_state tail etat_searched

let get_first (x, y) = 
    x

let get_first tuple = 
    match tuple with
    | (x, y) -> x (*Si tuple contient 2 elements alors on affiche le premier*)

let get_second tuple = 
    match tuple with
    | (x, y) -> y