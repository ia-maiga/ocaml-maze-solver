(** Maze grids.

    A maze is stored exactly as it appears in a [.laby] file: a rectangle of
    characters where
    - ['+'], ['-'] and ['|'] are walls,
    - [' '] is a free cell,
    - ['S'] is the start and ['E'] the exit,
    - ['R'] marks a cell of the solution path (written by the solver).

    Positions are given as [(line, column)], starting from [(0, 0)] in the
    top-left corner. *)

type t
(** The type of maze grids (mutable). *)

exception Invalid_maze of string
(** Raised when a file or a list of lines does not describe a valid maze. The
    string explains the problem. *)

(** {1 Building and printing} *)

val of_lines : string list -> t
(** [of_lines lines] builds a grid from its text lines. Checks that the grid is
    non-empty, rectangular, uses only allowed characters, and contains exactly
    one ['S'] and one ['E'].
    @raise Invalid_maze otherwise. *)

val from_file : in_channel -> t
(** [from_file c_in] reads every line of [c_in] and builds the grid.
    @raise Invalid_maze if the content is not a valid maze. *)

val make : int -> int -> char -> t
(** [make height width c] creates a [height x width] grid filled with [c]. *)

val output : out_channel -> t -> unit
(** [output c_out g] writes [g] in the [.laby] format. *)

val print : t -> unit
(** [print g] writes [g] on the standard output. *)

(** {1 Access} *)

val height : t -> int
val width : t -> int

val get : t -> int -> int -> char
(** [get g l c] is the character at line [l], column [c]. *)

val set : t -> int -> int -> char -> unit
(** [set g l c ch] replaces the character at line [l], column [c]. *)

val in_bounds : t -> int -> int -> bool
(** [in_bounds g l c] is [true] iff [(l, c)] is a position of [g]. *)

val is_wall : char -> bool
(** [is_wall ch] is [true] for ['+'], ['-'] and ['|']. *)

val find : t -> char -> int * int
(** [find g ch] is the position of the first occurrence of [ch].
    @raise Not_found if [ch] does not appear in [g]. *)
