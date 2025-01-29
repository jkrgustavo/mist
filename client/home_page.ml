open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

(* TODO: This shouldn't return an option, just return the Or_error *)
let fetch ~url =
    let open Ui_effect.Let_syntax in
    let e_data = Effect.of_deferred_fun (fun () -> Async_js.Http.get url) () in
    let%bind data = e_data in
    match data with
    | Ok d -> return (Some d)
    | Error e ->
        let error_str = Error.to_string_hum e in
        print_endline [%string "==============%{error_str}=============="];
        return None
;;

let splash_component =
    let%sub splash, set_splash = Bonsai.state_opt () in
    let%sub callback =
        let%arr set_splash = set_splash in
        fun old () ->
          let%bind.Effect fetched = fetch ~url:"/static/splash.txt" in
          match old with
          | None -> set_splash fetched
          | _ -> Effect.alert "oop"
    in
    let%sub () =
        Bonsai.Edge.on_change' ~equal:(fun () () -> false) ~callback (Bonsai.Value.return ())
    in
    let%arr splash = splash in
    let open Vdom in
    Node.div
      [ ( match splash with
          | Some s -> Node.pre [ Node.text s ]
          | None -> Node.text "Loading..."
        )
      ]
;;

let component ~set_route =
    let%sub splash_component = splash_component in
    let%arr splash_component = splash_component and _set_route = set_route in
    let open Vdom in
    Node.div
      ~attrs:[ Attr.classes [ "homepage" ] ]
      [ splash_component
      ; Node.h1 [ Node.text "This is the Homepage header" ]
      ; Node.div
          ~attrs:[ Attr.classes [ "home-nav" ] ]
            [
          (* [ Menu.st_button ~label:"to page 1" ~set_state:set_route ~state:(Route.Post "post 1") *)
          (* ; Menu.st_button ~label:"to page 2" ~set_state:set_route ~state:(Route.Post "post 2") *)
          (* ; Menu.st_button ~label:"to page 3" ~set_state:set_route ~state:(Route.Post "post 3") *)
          (* ; Menu.st_button ~label:"to page 4" ~set_state:set_route ~state:(Route.Post "post 4") *)
          ]
      ]
;;
