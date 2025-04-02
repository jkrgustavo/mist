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


let build_site fs = (fs_data fs) :: create_routes fs

let cors_middleware handler req =
    let open Dream in
    let origin_opt = Dream.header req "origin" in
    let origin = Option.value origin_opt ~default:"*" in
    match method_ req with
    | `OPTIONS ->
        print_endline "testing...";
        respond ~headers:[
            "Access-Control-Allow-Origin", origin;
            "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS";
            "Access-Control-Allow-Headers", "Content-Type, Authorization";
            "Access-Control-Max-Age", "3600";
        ] ""
    | _ ->
        let response_promise = handler req in
        Lwt.map (fun response ->
            match origin_opt with
            | Some origin ->
                Dream.add_header response "Access-Control-Allow-Origin" origin;
                Dream.add_header response "Access-Control-Allow-Credentials" "true";
                response
            | None -> response
        ) response_promise

let () =
    print_endline "";
    Files.build_tree "dummy-fs"
    |> Files.sort_tree
    |> build_site
    |> Dream.router
    |> cors_middleware
    |> Dream.logger
    |> Dream.run
;;
