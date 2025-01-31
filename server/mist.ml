(* TODO: Use s-expressions instead of json *)
let to_json file =
    let open Files in
    match file with
    | File (name, cont) ->
        UFile (name, Lazy.force cont) |> urgent_fs_to_yojson |> Yojson.Safe.to_string
    | Dir (_, children) ->
        let names =
            List.fold_left
              (fun acc -> function
                | File (name, _) -> Filename.basename name :: acc
                | Dir (name, _) -> Filename.basename name :: acc)
              [] children
        in
        `List (List.map (fun s -> `String s) names) |> Yojson.Safe.to_string
;;

(* TODO: Use a single route and parse the url (i.e. "localhost:8000/api:dir1-dir2-foo") *)
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
