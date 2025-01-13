open! Core
open! Bonsai_web
open Bonsai.Let_syntax

module Route = struct
  type t =
      | Home
      | Post of string
  [@@deriving sexp, equal]

  let to_string exp = exp |> sexp_of_t |> Sexp.to_string
end

let app =
    let%sub current_route, set_route = Bonsai.state Route.Home in
    let%sub menu_button = Menu.menu_button in
    let%arr current_route = current_route
    and set_route = set_route
    and menu_button = menu_button in
    let open Vdom in
    Node.div
      ~attrs:[ Attr.classes [ "root" ] ]
      [ Node.h1
          ~attrs:[ Attr.classes [ "header" ] ]
          [ Node.text ("The current route is: " ^ Route.to_string current_route) ]
      ; menu_button
      ; Menu.st_button ~label:"To Home" ~set_state:set_route ~state:Route.Home
      ]
;;

let () = Start.start app
