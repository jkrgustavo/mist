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
                <title>Bonsai Test</title>
            </head>
            <body>
                <div id="app" class="app"></div>
                <script src="/static/fog.bc.js"></script>
                <link rel="stylesheet" href="/static/styles.css">
                <!-- or main.js if using (modes (native js)) -->
            </body>
        </html>
        |})
;;

let static_js = Dream.get "/static/**" (Dream.static "static/")

let build_site pgs = main_page :: static_js :: create_routes pgs

let () =
    (* read_line () *)
    print_endline "";
    "dummy-fs"
    |> Files.build_tree
    |> build_site
    |> Dream.router
    |> Dream.logger
    |> Dream.run
;;
