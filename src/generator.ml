(* Randomized depth-first search ("recursive backtracker").

   We work on a [height x width] array of rooms. Room (i, j) is drawn at
   position (2i + 1, 2j + 1) of the character grid; the characters between
   two rooms are walls that we remove ("carve") when we move from one room to
   the other.

   1. Start with every wall closed and put the first room on a stack.
   2. Look at the room on top of the stack:
      - if it has unvisited neighbours, pick one at random, remove the wall
        between them, mark it visited and push it;
      - otherwise, pop it (dead end: we backtrack).
   3. Stop when the stack is empty: every room has been visited.

   Each room is entered exactly once, so the passages form a spanning tree of
   the rooms: the maze is perfect. An explicit stack (instead of recursion)
   avoids stack overflows on large mazes. *)

let directions = [| (-1, 0); (1, 0); (0, -1); (0, 1) |]

(* Grid with every wall closed: '+' at corners, '-' and '|' between rooms. *)
let closed_grid ~width ~height =
  let g = Grid.make ((2 * height) + 1) ((2 * width) + 1) ' ' in
  for l = 0 to 2 * height do
    for c = 0 to 2 * width do
      let ch =
        match (l mod 2 = 0, c mod 2 = 0) with
        | true, true -> '+'
        | true, false -> '-'
        | false, true -> '|'
        | false, false -> ' '
      in
      Grid.set g l c ch
    done
  done;
  g

let generate ~width ~height ~seed =
  if width <= 0 || height <= 0 || width * height < 2 then
    invalid_arg "Generator.generate: need positive dimensions and at least 2 rooms";
  let rng = Random.State.make [| seed |] in
  let g = closed_grid ~width ~height in
  let visited = Array.make_matrix height width false in
  let stack = Stack.create () in

  let unvisited_neighbours (i, j) =
    Array.to_list directions
    |> List.filter_map (fun (di, dj) ->
           let ni = i + di and nj = j + dj in
           if ni >= 0 && ni < height && nj >= 0 && nj < width
              && not visited.(ni).(nj)
           then Some (ni, nj)
           else None)
  in

  visited.(0).(0) <- true;
  Stack.push (0, 0) stack;
  while not (Stack.is_empty stack) do
    let ((i, j) as room) = Stack.top stack in
    match unvisited_neighbours room with
    | [] -> ignore (Stack.pop stack)
    | neighbours ->
        let ni, nj =
          List.nth neighbours
            (Random.State.int rng (List.length neighbours))
        in
        (* The wall between two rooms is halfway between their positions. *)
        Grid.set g (i + ni + 1) (j + nj + 1) ' ';
        visited.(ni).(nj) <- true;
        Stack.push (ni, nj) stack
  done;

  Grid.set g 1 1 'S';
  Grid.set g ((2 * height) - 1) ((2 * width) - 1) 'E';
  g
