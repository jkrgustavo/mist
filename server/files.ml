open Sexplib.Std

type page =
    | Page of { path: string; content: string }
    | Index of { path: string; children: string list }
[@@deriving sexp]

type fsData =
    | F of string
    | D of { path: string; children: fsData list}
[@@deriving sexp];;

type filesystem =
    | File of (string * string lazy_t)
    | Dir of (string * filesystem list)
[@@deriving sexp]

let fname = function
    | File (n, _) -> n
    | Dir (n, _) -> n
;;


let read_file path =
    let ch = open_in_bin path in
    let len = in_channel_length ch in
    let byte = Bytes.create len in
    really_input ch byte 0 len;
    close_in ch;
    byte
;;

let trim_extension name = try Filename.chop_extension name with Invalid_argument _ -> name

let decide a b =
    match (a, b) with
    | File _, Dir _ -> -1
    | Dir _, File _ -> 1
    | _, _ -> String.compare (fname a) (fname b)
;;

let rec sort_tree = function
    | File _ as f -> f
    | Dir (name, chil) -> Dir (name, List.sort decide chil |> (List.map sort_tree))
;;

let render_markdown md =
    let doc = Cmarkit.Doc.of_string md in
    Cmarkit_html.of_doc doc ~safe:true
;;

let rec build_tree ?(rpath = "api") (path : string) : filesystem =
    if Sys.is_directory path then
        let child_to_fs child =
            Filename.(concat path child |> build_tree ~rpath:(concat rpath child))
        in
        let children = Sys.readdir path |> Array.to_list |> List.map child_to_fs in
        Dir (rpath, children)
    else
        let html = lazy (read_file path |> Bytes.to_string |> render_markdown) in
        File (trim_extension rpath, html)
;;

let rec print_filesystem ?(indent = 0) fs =
    let indent_str = String.make indent ' ' in
    match fs with
    | File (path, _contents) -> Printf.printf "%sFile: %s\n" indent_str path
    | Dir (path, sub) ->
        Printf.printf "%sDir: %s\n" indent_str path;
        List.iter (fun child -> print_filesystem ~indent:(indent + 2) child) sub
;;
