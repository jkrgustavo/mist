type page = {
  name : string;
  html : string;
}

let elt_to_string elt = Fmt.str "%a" (Tyxml.Html.pp_elt ()) elt

let markdown_to_page f =
    let open Files in
    match f with
    | File (name, md) ->
        let doc = Cmarkit.Doc.of_string (Lazy.force md) in
        let html = Cmarkit_html.of_doc doc ~safe:true in
        { name; html }
    | _ -> raise (Failure "Cant serve a plain directory!")
;;

let make_homepage (pages : page list) =
    let module Html = Tyxml_html in
    let links_li =
        List.map
          (fun { name; _ } ->
            let addr = Printf.sprintf "http://localhost:8080/%s" name in
            Html.li [ Html.a ~a:[ Html.a_href addr ] [ Html.txt name ] ])
          pages
    in
    let page =
        Html.html
          (Html.head (Html.title (Html.txt "Homepage")) [])
          (Html.body [ Html.h1 [ Html.txt "Welcome!" ]; Html.ul links_li ])
    in
    { name = "/"; html = elt_to_string page }
;;

let homepage (pages : page list) =
    let open Tyxml in
    let links =
        List.map
          (fun { name; _ } ->
            let addr = Printf.sprintf "http://localhost:8080/%s" name in
            Html.([%html "<li><a href=" addr ">" [ txt name ] "</a></li>"]))
          pages
    in
    let elm =
        Html.([%html
            "<html>
                <head>
                    <title>" (txt "Sup!") "</title>
                </head>
                <body>
                    <h1>"[ txt "Welcome!" ]"</h1>
                    <ul>" links "</ul>
                </body>
            </html>"])
    in
    { name = "/"; html = elt_to_string elm }
;;

let create_routes pages =
    let site = homepage pages :: pages in
    List.map (fun page -> Dream.get page.name (fun _ -> Dream.html page.html)) site
;;
