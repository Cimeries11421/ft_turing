open Core

let rec deux_puissance (n : float) : float =
  if Float.(n < 0.) then invalid_arg "n doit être positif"
  else if Float.(n = 0.) then 1.
  else 2. *. deux_puissance (n -. 1.)

let rec compareConstants (count : int list) : bool =
    match count with
    | r1 :: r2 :: rest ->
        if r1 = r2 then
            compareConstants (r2 :: rest)
        else
            false
    | _ -> true

let rec compareRatios (ratios : float list) : bool =
    match ratios with
    | r1 :: r2 :: rest ->
        if Float.(abs (r1 - r2) <= 0.2 * max r1 r2) then
            compareRatios (r2 :: rest)
        else
            false
    | _ -> true

type complexity = Linear | Quadratic | Logarithmic | Linearithmic | Exponential

let rec computeUnitsPerStep (curve : complexity) (tapes : (string * int) list) : float list =
    match tapes with
    | (shortTape, shortCount) :: ((longTape, longCount) :: rest) ->
        let shortSize : float = Float.of_int (String.length shortTape) in
        let longSize : float = Float.of_int (String.length longTape) in
        let extraSteps : float = Float.of_int (longCount - shortCount) in
        let extraSize : float =
            match curve with
            | Logarithmic -> (Float.log longSize) -. (Float.log shortSize)
            | Linear    -> longSize -. shortSize
            | Linearithmic -> (longSize *. Float.log longSize) -. (shortSize *. Float.log shortSize)
            | Quadratic -> (longSize *. longSize) -. (shortSize *. shortSize)
            | Exponential -> (deux_puissance longSize) -. (deux_puissance shortSize)
        in
        let unitsPerStep : float = extraSize /. extraSteps in
            unitsPerStep :: computeUnitsPerStep curve rest
    | _ -> []

let check_Constant_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : int list = List.map sortedTapes ~f:(fun ((_ : string), (count : int)) -> count)
    in
        compareConstants stepsPerSquareList

let check_Linear_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerCellList : float list = computeUnitsPerStep Linear sortedTapes in
        compareRatios stepsPerCellList

let check_Logarithmic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Logarithmic sortedTapes in
        compareRatios stepsPerSquareList

let check_Quadratic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Quadratic sortedTapes in
        compareRatios stepsPerSquareList

let check_Linearithmic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Linearithmic sortedTapes in
        compareRatios stepsPerSquareList

let check_Exponential_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Exponential sortedTapes in
        compareRatios stepsPerSquareList

let printComplexity (tapes : (string * int) list) : unit =
    let sortedTapes : ((string * int) list) = List.sort tapes ~compare: (fun ((tape1 : string), (_ : int)) ((tape2 : string), (_ : int))
    ->
        Int.compare (String.length tape1) (String.length tape2)
    )
    in
        if check_Constant_time_complexity sortedTapes then
            print_endline "Complexity: O(1)"
        else if check_Logarithmic_time_complexity sortedTapes then
            print_endline "Complexity: O(log n)"
        else if check_Linear_time_complexity sortedTapes then
            print_endline "Complexity: O(n)"
        else if check_Linearithmic_time_complexity sortedTapes then
            print_endline "Complexity: O(n log n)"
        else if check_Quadratic_time_complexity sortedTapes then
            print_endline "Complexity: O(n^2)"
        else if check_Exponential_time_complexity sortedTapes then
            print_endline "Complexity: O(2^n)"
        else
            print_endline "Complexity: greater than O(2^n) or unknown"

