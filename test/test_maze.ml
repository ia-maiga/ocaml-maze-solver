(* Unit tests, run with [dune test]. *)

open Labyrinth

let passed = ref 0
let failed = ref 0

let check name cond =
  if cond then incr passed
  else begin
    incr failed;
    Printf.printf "FAIL: %s\n" name
  end

let raises_invalid f =
  match f () with
  | _ -> false
  | exception Grid.Invalid_maze _ -> true

let load file =
  let c_in = open_in file in
  let g = Grid.from_file c_in in
  close_in c_in;
  g

let to_lines g =
  List.init (Grid.height g) (fun l ->
      String.init (Grid.width g) (fun c -> Grid.get g l c))

let examples =
  [ "maze_2x1"; "maze_3x2"; "maze_4x8"; "maze_6x6"; "maze_100x100" ]
  |> List.map (fun n -> "../examples/" ^ n ^ ".laby")

(* The solution is valid if, starting from S and walking only on R cells, we
   reach E. *)
let path_is_valid g =
  let h = Grid.height g and w = Grid.width g in
  let seen = Array.make_matrix h w false in
  let rec walk l c =
    Grid.in_bounds g l c
    && (not seen.(l).(c))
    &&
    match Grid.get g l c with
    | 'E' -> true
    | 'S' | 'R' ->
        seen.(l).(c) <- true;
        walk (l - 1) c || walk (l + 1) c || walk l (c - 1) || walk l (c + 1)
    | _ -> false
  in
  let l, c = Grid.find g 'S' in
  walk l c

(* In a perfect maze of n rooms, exactly n - 1 walls between rooms are open
   (the passages form a tree). Walls between rooms are the cells with exactly
   one odd coordinate. *)
let open_walls g =
  let n = ref 0 in
  for l = 1 to Grid.height g - 2 do
    for c = 1 to Grid.width g - 2 do
      if (l + c) mod 2 = 1 && Grid.get g l c = ' ' then incr n
    done
  done;
  !n

(* ------------------------------------------------------------------ *)

let test_parsing () =
  let g = load "../examples/maze_6x6.laby" in
  check "6x6 has 13 lines" (Grid.height g = 13);
  check "6x6 has 13 columns" (Grid.width g = 13);
  check "start position" (Grid.find g 'S' = (1, 1));
  List.iter
    (fun file ->
      let g = load file in
      check ("round trip " ^ file)
        (to_lines g = to_lines (Grid.of_lines (to_lines g))))
    examples

let test_invalid_files () =
  check "empty file" (raises_invalid (fun () -> Grid.of_lines []));
  check "lines of different lengths"
    (raises_invalid (fun () -> Grid.of_lines [ "+-+"; "|S|E"; "+-+" ]));
  (* Regression: the original version only compared lines 1-2, 3-4, ... *)
  check "only lines 2 and 3 differ"
    (raises_invalid (fun () ->
         Grid.of_lines [ "+-+-+"; "|S E|"; "+-+-"; "+-+-" ]));
  check "forbidden character"
    (raises_invalid (fun () -> Grid.of_lines [ "+-+-+"; "|SZE|"; "+-+-+" ]));
  check "no start"
    (raises_invalid (fun () -> Grid.of_lines [ "+-+-+"; "|  E|"; "+-+-+" ]));
  check "two exits"
    (raises_invalid (fun () -> Grid.of_lines [ "+-+-+"; "|SEE|"; "+-+-+" ]));
  check "trailing empty line accepted"
    (not
       (raises_invalid (fun () -> Grid.of_lines [ "+-+-+"; "|S E|"; "+-+-+"; "" ])))

let test_solver () =
  List.iter
    (fun file ->
      let g = load file in
      check ("solvable " ^ file) (Solver.solve g);
      check ("valid path " ^ file) (path_is_valid g))
    examples;
  let lines = [ "+-+-+"; "|S| |"; "+-+ +"; "|  E|"; "+-+-+" ] in
  let g = Grid.of_lines lines in
  check "no solution detected" (not (Solver.solve g));
  check "grid unchanged when no solution" (to_lines g = lines)

let test_generator () =
  List.iter
    (fun (width, height, seed) ->
      let name = Printf.sprintf "%dx%d seed %d" width height seed in
      let g = Generator.generate ~width ~height ~seed in
      check (name ^ ": size")
        (Grid.height g = (2 * height) + 1 && Grid.width g = (2 * width) + 1);
      check (name ^ ": valid file format")
        (not (raises_invalid (fun () -> Grid.of_lines (to_lines g))));
      check (name ^ ": perfect maze") (open_walls g = (width * height) - 1);
      check (name ^ ": solvable") (Solver.solve g && path_is_valid g))
    [ (2, 1, 0); (1, 5, 3); (10, 10, 42); (25, 7, 1); (60, 40, 2026) ];
  let a = Generator.generate ~width:15 ~height:15 ~seed:7 in
  let b = Generator.generate ~width:15 ~height:15 ~seed:7 in
  let c = Generator.generate ~width:15 ~height:15 ~seed:8 in
  check "same seed, same maze" (to_lines a = to_lines b);
  check "different seed, different maze" (to_lines a <> to_lines c)

let () =
  test_parsing ();
  test_invalid_files ();
  test_solver ();
  test_generator ();
  Printf.printf "%d tests passed, %d failed\n" !passed !failed;
  if !failed > 0 then exit 1
