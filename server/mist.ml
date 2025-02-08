(* TODO: Serialize to s-exp. Currently contains a lot of unneeded information 
    Maybe like: 
        (file 
            (name ...)
            (contents ...))
        (dir 
            (name ...)
            (children 
                (file 'name')
                (dir 'name1')
                (dir 'name2')))
    Prob need to make the file logic it's own library to share the code

    Use Sexp lib, instead of UFile and UDir make it a record and deserialize
    in client code using vendored lib
*)

let to_json file =
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

let rec create_routes pgs =
    let open Files in
    match pgs with
    | File (title, html) ->
        [ Dream.get title (fun _ -> File (title, html) |> to_json |> Dream.json) ]
    | Dir (title, children) ->
        let index =
            Dream.get title (fun _ -> Dir (title, children) |> to_json |> Dream.html)
        in
        List.map create_routes children |> List.concat |> List.cons index
;;

let main_page =
    Dream.get "/" (fun _ ->
        Dream.html
          {|
        <!DOCTYPE html>
        <html lang="en">
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

let build_site pgs = main_page :: static_js :: create_routes pgs

let () =
    print_endline "";
    "dummy-fs"
    |> Files.build_tree
    |> build_site
    |> Dream.router
    |> Dream.logger
    |> Dream.run
;;
