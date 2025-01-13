type urgent_fs =
    | UFile of (string * string)
    | UDir of (string * urgent_fs list)
[@@deriving yojson]

type filesystem = 
    | File of (string * string lazy_t) 
    | Dir of (string * filesystem list)

val build_tree: ?rpath:string -> string -> filesystem
val print_filesystem: ?indent: int -> filesystem -> unit
