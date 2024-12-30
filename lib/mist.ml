
let main () =
    Files.build_tree "dummy-fs"
    |> Files.collapse_dir
    |> List.map Page.markdown_to_page
    |> Page.create_routes
    |> Dream.router
    |> Dream.logger
    |> Dream.run
;;
