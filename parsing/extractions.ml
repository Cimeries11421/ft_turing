open Core

let extract_array_value line = 
  match String.index line ':' with
  | None -> None
  | Some pos ->
		let value = String.strip (String.sub line ~pos:(pos + 1) ~len:(String.length line - pos - 1))
		in
    let value = 
      Option.value
        (String.chop_suffix value ~suffix:",") ~default:value
    in
    let value =
      Option.value
        (String.chop_prefix value ~prefix:"[") ~default:value
    in
    let value =
      Option.value
        (String.chop_suffix value ~suffix:"]") ~default:value
    in
    Some (String.strip value)

let extract_value line =
  match String.index line ':' with
  | None -> None
  | Some pos ->
		let value = String.strip (String.sub line ~pos:(pos + 1) ~len:(String.length line - pos - 1))
		in
		let value = 
			Option.value (String.chop_suffix value ~suffix:",") ~default:value 
		in
		let value = 
			Option.value (String.chop_suffix value ~suffix:"\"") ~default:value 
		in
		let value =
			Option.value (String.chop_prefix value ~prefix:"\"") ~default:value 
		in
		Some value

let extract_alphabet line =
  match extract_array_value line with
  | None -> None
  | Some value ->
    let items = String.split value ~on:',' in
    let characters = List.filter_map items ~f:(fun item ->
      let item = String.strip item in
      let item =
        Option.value
          (String.chop_prefix item ~prefix:"\"") ~default:item
      in
      let item =
        Option.value
          (String.chop_suffix item ~suffix:"\"") ~default:item
      in
      if String.length item = 1 then Some item.[0]
      else None
    )
    in Some characters

let extract_finals line =
  match extract_array_value line with
  | None -> None
  | Some value ->
    let items = String.split value ~on:',' in
    let finals = List.filter_map items ~f:(fun item ->
      let item = String.strip item in
      let item =
        Option.value
          (String.chop_prefix item ~prefix:"\"") ~default:item
      in
      let item =
        Option.value
          (String.chop_suffix item ~suffix:"\"") ~default:item
      in
      if String.is_empty item then None
      else Some item
    )
    in Some finals
    

(* let extract_action value =
  match String.strip value with
  | "LEFT" -> Some "LEFT"
  | "RIGHT" -> Some "RIGHT"
  | _ -> None *)

(* let extraction_transition  *)