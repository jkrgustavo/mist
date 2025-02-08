type page =
    | Page of { path: string; content: string }
    | Index of { path: string; children: string list }
[@@deriving yojson, sexp]

type filesystem = 
    | File of (string * string lazy_t) 
    | Dir of (string * filesystem list)

val build_tree: ?rpath:string -> string -> filesystem
val print_filesystem: ?indent: int -> filesystem -> unit
