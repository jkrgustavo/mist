open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

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
        let callback old () =
            let%bind.Effect fetched = fetch ~url:"/static/splash.txt" in
            match old with
            | None -> set_splash fetched
            | _ -> Effect.alert "oop"
        in
        callback
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

let component ~_set_route =
    let%sub splash_component = splash_component in
    let%arr splash_component = splash_component in
    let open Vdom in
    Node.div
      ~attrs:[ Attr.classes [ "homepage" ] ]
        [ splash_component; Node.h1 [ Node.text "This is the Homepage header" ] ]
;;
