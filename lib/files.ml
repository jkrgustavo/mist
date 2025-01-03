type 'a filesystem = File of (string * 'a) | Dir of (string * 'a filesystem list)

let read_file path =
    let ch = open_in_bin path in
    let len = in_channel_length ch in
    let byte = Bytes.create len in
    really_input ch byte 0 len;
    close_in ch;
    byte
;;

let trim_extension name =
  try Filename.chop_extension name
  with Invalid_argument _ -> name
;;

let render_markdown md =
    let doc = Cmarkit.Doc.of_string md in
    Cmarkit_html.of_doc doc ~safe:true
;;

let rec build_tree (path : string) =
    match Sys.is_directory path with
    | true ->
        let build_children child = build_tree @@ Filename.concat path child in
        let children = List.map build_children (Sys.readdir path |> Array.to_list) in
        Dir (Filename.basename path, children)
    | false ->
        let name = Filename.basename path |> trim_extension in
        let html = read_file path |> Bytes.to_string |> render_markdown in
        File (name, html)
;;

let rec print_filesystem ?(indent = 0) fs =
    let indent_str = String.make indent ' ' in
    match fs with
    | File (path, _contents) -> Printf.printf "%sFile: %s\n" indent_str path
    | Dir (path, sub) ->
        Printf.printf "%sDir: %s\n" indent_str path;
        List.iter (fun child -> print_filesystem ~indent:(indent + 2) child) sub
;;
