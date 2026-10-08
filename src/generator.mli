(** Random maze generation. *)

val generate : width:int -> height:int -> seed:int -> Grid.t
(** [generate ~width ~height ~seed] builds a random {e perfect} maze of
    [width x height] rooms: every room is reachable and there is exactly one
    path between any two rooms. The start ['S'] is in the top-left room and
    the exit ['E'] in the bottom-right room. The same seed always gives the
    same maze.

    The resulting grid has [2 * height + 1] lines and [2 * width + 1]
    columns (rooms plus the walls around them).
    @raise Invalid_argument if a dimension is not positive or if there is
    only one room (start and exit must differ). *)
