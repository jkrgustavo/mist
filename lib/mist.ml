
let rec create_routes pgs =
    let open Page in
    match pgs with
    | Page (title, html) ->
        [ Dream.get title (fun _ -> Dream.html html) ]
    | Index (title, html, children) ->
        let index = Dream.get title (fun _ -> Dream.html html) in
        List.map create_routes children |> List.concat |> List.cons index
;;

let to_pages filesys =
    let open Files in
    let open Page in
    let root =
        match filesys with
        | Dir (_, ch) -> Dir ("", ch)
        | _ -> failwith "Handle errors better from within 'to_pages'"
    in
    let pages = fs_to_page filesys in
    match pages with
    | Page p -> Page p
    | Index (_, _, children) -> Index ("/", homepage root, children)
;;

let main () =
    read_line ()
    |> Files.build_tree
    |> to_pages
    |> create_routes
    |> Dream.router
    |> Dream.logger
    |> Dream.run ~error_handler:(Dream.error_template Page.error_template)
;;
