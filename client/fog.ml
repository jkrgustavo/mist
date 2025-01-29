open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

(* TODO: /api has a list of every post, create a list of links for each post and pass that
 *  to Post.component. For sub dirs, just GET /api ^ curr-url to make index pages of children
*)

let app =
    let%sub current_route, set_route = Bonsai.state Route.Home in
    let%sub menu = Menu.component in
    let%sub page =
        match%sub current_route with
        | Route.Home -> Home_page.component ~set_route
        | Route.Post s ->
            let%arr s = s and set_route = set_route in
            Post.component ~url:s ~set_route
    in
    let%arr menu = menu and page = page in
    Vdom.Node.div ~attrs:[ Vdom.Attr.classes [ "root" ] ] [ menu; page ]
;;

let () = Start.start app
