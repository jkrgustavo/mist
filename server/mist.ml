let to_sexp file =
    let open Files in
    let open Sexplib in
    match file with
    | File (name, cont) ->
        Page { path=name; content=Lazy.force cont } |> sexp_of_page |> Sexp.to_string_mach
    | Dir (name, children) ->
        let names =
            List.fold_left
              (fun acc -> function
                | File (name, _) -> Filename.basename name :: acc
                | Dir (name, _) -> Filename.basename name :: acc)
              [] children
        in
        Index { path=name; children=names } |> sexp_of_page |> Sexp.to_string_mach
;;

let rec create_routes fs =
    let open Files in
    match fs with
    | File (title, html) ->
        [ Dream.get title (fun _ -> File (title, html) |> to_sexp |> Dream.json) ]
    | Dir (title, children) ->
        let index =
            Dream.get title (fun _ -> Dir (title, children) |> to_sexp |> Dream.html)
        in
        List.map create_routes children |> List.concat |> List.cons index
;;

let main_page =
    Dream.get "/" (fun _ ->
        Dream.html
          {|
        <!DOCTYPE html>
        <html lang="en" class="dark">
            <head>
                <meta charset="utf-8"/>
                <title>Mist</title>
                <script type="module" src="/static/js/main.js"></script>
            </head>
            <body>
                <div id="root" class="root"></div>
                <link rel="stylesheet" href="/static/styles.css">
            </body>
        </html>
        |})
;;

let static_js = Dream.get "/static/**" (Dream.static "static/")

let fs_data fs =
    let open Files in
    let open Sexplib in
    let rec build files = 
        match files with
        | File (name, _) -> F (name)
        | Dir (path, children) -> D { path; children=(List.map(fun ch -> build ch) children) }
    in
    Dream.get "/fs" (fun _ -> build fs |> sexp_of_fsData |> Sexp.to_string_hum |> Dream.html)
;;


let build_site fs = main_page :: static_js :: (fs_data fs) :: create_routes fs

let () =
    print_endline "";
    Files.build_tree "dummy-fs"
    |> Files.sort_tree
    |> build_site
    |> Dream.router
    |> Dream.logger
    |> Dream.run
;;
