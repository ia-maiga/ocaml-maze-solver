(* Depth-first search from the start cell.

   [explore l c] returns [true] if the exit can be reached from (l, c). The
   path is marked on the way back: when a neighbour leads to the exit, the
   current cell is part of the path. Thanks to [||], the search stops as soon
   as one direction succeeds. *)

let solve g =
  let visited =
    Array.make_matrix (Grid.height g) (Grid.width g) false
  in
  let rec explore l c =
    if not (Grid.in_bounds g l c) || visited.(l).(c) then false
    else
      let ch = Grid.get g l c in
      if ch = 'E' then true
      else if Grid.is_wall ch then false
      else begin
        visited.(l).(c) <- true;
        let found =
          explore (l - 1) c (* up *)
          || explore (l + 1) c (* down *)
          || explore l (c + 1) (* right *)
          || explore l (c - 1) (* left *)
        in
        if found && ch <> 'S' then Grid.set g l c 'R';
        found
      end
  in
  let l, c = Grid.find g 'S' in
  explore l c
