(* Command-line interface.

   Exit codes:
     0  success
     1  invalid command line
     2  file cannot be opened
     3  invalid maze file
     4  maze has no solution
     5  maze too large for the recursive solver *)

open Labyrinth

let usage =
  {|Usage:
  maze print  <file.laby>                     display a maze
  maze solve  <file.laby>                     display a maze with its solution ('R')
  maze random <width> <height> <seed> [file]  generate a random maze
                                              (printed, or written to [file])
  maze --help                                 show this message|}

let fail code fmt =
  Printf.ksprintf
    (fun msg ->
      flush stdout;
      prerr_endline ("Error: " ^ msg);
      exit code)
    fmt

(* Opens and parses a maze file, turning every failure into a clear message
   and a specific exit code. *)
let load filename =
  let c_in =
    try open_in filename
    with Sys_error _ -> fail 2 "cannot open file '%s'" filename
  in
  match Grid.from_file c_in with
  | g ->
      close_in c_in;
      g
  | exception Grid.Invalid_maze msg ->
      close_in c_in;
      fail 3 "'%s' is not a valid maze: %s" filename msg

let int_arg name s =
  match int_of_string_opt s with
  | Some n when n > 0 -> n
  | _ -> fail 1 "%s must be a positive integer (got '%s')" name s

let random w h seed output =
  let width = int_arg "width" w and height = int_arg "height" h in
  let seed =
    match int_of_string_opt seed with
    | Some s -> s
    | None -> fail 1 "seed must be an integer (got '%s')" seed
  in
  if width * height < 2 then fail 1 "the maze needs at least 2 rooms";
  let g = Generator.generate ~width ~height ~seed in
  match output with
  | None -> Grid.print g
  | Some filename ->
      let c_out =
        try open_out filename
        with Sys_error _ -> fail 2 "cannot write file '%s'" filename
      in
      Grid.output c_out g;
      close_out c_out;
      Printf.printf "Maze %dx%d (seed %d) written to %s\n" width height seed
        filename

let () =
  match Array.to_list Sys.argv with
  | [ _; ("--help" | "-h" | "help") ] -> print_endline usage
  | [ _; "print"; file ] -> Grid.print (load file)
  | [ _; "solve"; file ] ->
      let g = load file in
      let found =
        try Solver.solve g
        with Stack_overflow ->
          fail 5 "maze too large for the recursive solver (stack overflow)"
      in
      if found then Grid.print g
      else begin
        Grid.print g;
        fail 4 "no path from S to E"
      end
  | [ _; "random"; w; h; seed ] -> random w h seed None
  | [ _; "random"; w; h; seed; file ] -> random w h seed (Some file)
  | _ ->
      prerr_endline usage;
      exit 1
