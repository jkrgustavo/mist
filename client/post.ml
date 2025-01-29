open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

(* TODO: Fetch post based on the url and render it *)
let component ~url ~set_route =
    Vdom.Node.div
      [ Vdom.Node.h1 [ Vdom.Node.text [%string "%{url} (unimplemented)"] ]
      ; Menu.st_button ~label:"Back to home" ~set_state:set_route ~state:Route.Home
      ]
;;
