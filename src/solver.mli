(** Maze solving. *)

val solve : Grid.t -> bool
(** [solve g] looks for a path from ['S'] to ['E'] moving up, down, left or
    right through non-wall cells, using a recursive depth-first search.

    If a path exists, every cell of the path (except ['S'] and ['E']) is
    replaced by ['R'] in [g] and the result is [true]. Otherwise [g] is left
    unchanged and the result is [false]. *)
