type 'a filesystem = File of (string * 'a) | Dir of (string * 'a filesystem list)

val build_tree : string -> string filesystem
val print_filesystem : ?indent:int -> 'a filesystem -> unit
