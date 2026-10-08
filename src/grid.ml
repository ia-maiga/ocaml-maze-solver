type t = {
  height : int;
  width : int;
  cells : char array array;
}

exception Invalid_maze of string

let invalid fmt = Printf.ksprintf (fun msg -> raise (Invalid_maze msg)) fmt

let is_wall ch = ch = '+' || ch = '-' || ch = '|'

let is_allowed ch = is_wall ch || ch = ' ' || ch = 'S' || ch = 'E' || ch = 'R'

(* Reads all lines of a channel. Tail-recursive thanks to the exception
   pattern, so it also works on large files. Windows line endings are
   removed. *)
let read_file c_in =
  let strip_cr s =
    let n = String.length s in
    if n > 0 && s.[n - 1] = '\r' then String.sub s 0 (n - 1) else s
  in
  let rec loop acc =
    match input_line c_in with
    | s -> loop (strip_cr s :: acc)
    | exception End_of_file -> List.rev acc
  in
  loop []

(* Counts the occurrences of [ch] in the grid. *)
let count cells ch =
  Array.fold_left
    (fun acc row ->
      Array.fold_left (fun acc x -> if x = ch then acc + 1 else acc) acc row)
    0 cells

let of_lines lines =
  (* Trailing empty lines (e.g. a final newline) are ignored. *)
  let lines =
    List.rev lines |> List.fold_left
      (fun acc l -> if acc = [] && l = "" then [] else l :: acc)
      []
  in
  match lines with
  | [] -> invalid "empty file"
  | first :: _ ->
      let width = String.length first in
      List.iteri
        (fun i l ->
          if String.length l <> width then
            invalid "line %d has length %d, expected %d (grid not rectangular)"
              (i + 1) (String.length l) width;
          String.iteri
            (fun j ch ->
              if not (is_allowed ch) then
                invalid "unexpected character '%c' at line %d, column %d" ch
                  (i + 1) (j + 1))
            l)
        lines;
      let cells =
        Array.of_list
          (List.map (fun l -> Array.init width (fun j -> l.[j])) lines)
      in
      let nb_s = count cells 'S' and nb_e = count cells 'E' in
      if nb_s <> 1 then invalid "expected exactly one start 'S', found %d" nb_s;
      if nb_e <> 1 then invalid "expected exactly one exit 'E', found %d" nb_e;
      { height = Array.length cells; width; cells }

let from_file c_in = of_lines (read_file c_in)

let make height width c =
  { height; width; cells = Array.make_matrix height width c }

let output c_out g =
  Array.iter
    (fun row ->
      Array.iter (output_char c_out) row;
      output_char c_out '\n')
    g.cells

let print g = output stdout g

let height g = g.height
let width g = g.width
let get g l c = g.cells.(l).(c)
let set g l c ch = g.cells.(l).(c) <- ch
let in_bounds g l c = l >= 0 && l < g.height && c >= 0 && c < g.width

let find g ch =
  let rec search l c =
    if l >= g.height then raise Not_found
    else if c >= g.width then search (l + 1) 0
    else if g.cells.(l).(c) = ch then (l, c)
    else search l (c + 1)
  in
  search 0 0
