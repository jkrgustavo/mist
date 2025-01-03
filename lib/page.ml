type page = 
    | Page of (string * string)
    | Index of (string * string * page list)

let elt_to_string elt = Fmt.str "%a" (Tyxml.Html.pp_elt ()) elt


let make_children_links fs =
    let to_link name =
        let open Tyxml in
        let addr = Printf.sprintf "http://localhost:8080/%s" name in
        Html.([%html "<li><a href=" addr ">" [ txt name ] "</a></li>"])
    in
    let rec walk ?(parent = "") fs =
        match fs with
        | Files.File (name, _) -> [to_link (Filename.concat parent name)]
        | Files.Dir (name, children) ->
            (to_link (Filename.concat parent name)) :: (List.map (walk ~parent:name) children |> List.concat)
    in
    match fs with
    | Files.File f -> walk (File f)
    | Files.Dir (name, children) -> List.map (walk ~parent:name) children |> List.concat


;;

let homepage dir  =
    let open Tyxml in
    let links = make_children_links dir in
    let elm =
        Html.([%html
            "<html>
                <head>
                    <title>" (txt "Sup!") "</title>
                </head>
                <body>
                    <h1>"[ txt "This is the title page" ]"</h1>
                    <ul>" links "</ul>
                </body>
            </html>"])
    in
    elt_to_string elm
;;

let md_template name md =
    let open Tyxml in
    let open Html in
    let%html page (nm: string) (cont: string) = "
        <html>
            <head>
                <title>"(txt nm)"</title>
            </head>
            <body>
                <h1>"[txt "File!"]"</h1>
                "[Unsafe.data cont]
            "</body>
            </html>
        "
    in
    page name md |> elt_to_string
;;


let index_page dir =
    let open Tyxml in
    let links = make_children_links dir in
    let elm name =
        Html.([%html
            "<html>
                <head>
                    <title>" (txt name) "</title>
                </head>
                <body>
                    <h1>"[ txt "This is an index page" ]"</h1>
                    <ul>" links "</ul>
                </body>
            </html>"])
    in
    match dir with
    | Dir (name, _) -> elm name |> elt_to_string
    | _ -> failwith "Attempt to create an index page from a File!"
;;

let rec fs_to_page ?(parent = None) fs =
    let open Files in
    match fs with
    | File (name, content) ->
        let route = Filename.concat (Option.value ~default:"" parent) name in
        Page (route, md_template name content) 
    | Dir (name, children) ->
        let route = 
            if Option.is_none parent then "" 
            else Filename.concat (Option.value ~default:"" parent) name
        in
        Index (route, index_page (Dir (route, children)), List.map (fs_to_page ~parent:(Some route)) children)
;;

