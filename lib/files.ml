type 'a filesystem =
  | File of (string * 'a lazy_t)
  | Dir of (string * 'a filesystem array)

let read_file path =
    let ch = open_in_bin path in
    let len = in_channel_length ch in
    let byte = Bytes.create len in
    really_input ch byte 0 len;
    close_in ch;
    byte
;;

let rec build_tree (path : string) =
    if Sys.is_directory path then
      let name = Filename.basename path in
      let children =
          Array.map (fun child -> build_tree @@ Filename.concat path child) (Sys.readdir path)
      in
      Dir (name, children)
    else File (Filename.basename path, lazy (path |> read_file |> Bytes.to_string))
;;

let rec print_filesystem ?(indent = 0) fs =
    let indent_str = String.make indent ' ' in
    match fs with
    | File (fname, _contents) -> Printf.printf "%sFile: %s\n" indent_str fname
    (* Printf.printf "%s  contents: %s\n" indent_str (Lazy.force contents) *)
    | Dir (name, children) ->
        Printf.printf "%sDir: %s\n" indent_str name;
        Array.iter (fun child -> print_filesystem ~indent:(indent + 2) child) children
;;

let rec map_file_tree (fn : 'a -> 'b) (node : 'a filesystem) : 'b filesystem =
    match node with
    | File (name, contents) -> File (name, lazy (fn (Lazy.force contents)))
    | Dir (name, children) -> Dir (name, Array.map (map_file_tree fn) children)
;;

let rec collapse_dir ?(parent = "") (filesys : 'a filesystem) : 'a filesystem list =
    match filesys with
    | File (name, content) -> [ File (Filename.concat parent name, content) ]
    | Dir (name, children) ->
        let new_parent = Filename.concat parent name in
        children |> Array.to_list |> List.map (collapse_dir ~parent:new_parent) |> List.concat
;;
