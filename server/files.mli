type page =
    | Page of { path: string; content: string }
    | Index of { path: string; children: string list }
[@@deriving sexp]

type fsData =
    | F of string
    | D of { path: string; children: fsData list }
[@@deriving sexp]

type filesystem = 
    | File of (string * string lazy_t) 
    | Dir of (string * filesystem list)
[@@deriving sexp]


val build_tree: ?rpath:string -> string -> filesystem
val print_filesystem: ?indent: int -> filesystem -> unit
val sort_tree: filesystem -> filesystem
