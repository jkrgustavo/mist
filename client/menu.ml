open! Core
open! Bonsai_web
open! Bonsai.Let_syntax

module MenuState = struct
  type t =
      | Open
      | Closed
  [@@deriving sexp, equal]

  let to_string exp = exp |> sexp_of_t |> Sexp.to_string
  let flip st = if equal st Open then Closed else Open
  let is_open st = if equal st Open then true else false
  let is_closed st = if equal st Closed then true else false
end

let st_button ~label ~set_state ~state =
    let open Vdom in
    Node.button
      ~attrs:[ Attr.on_click (fun _ -> set_state state); Attr.classes [ "st_button" ] ]
      [ Node.text label ]
;;

let menu_opened ~set_opened =
    let open Vdom in
    let open MenuState in
    Node.div
      [ Node.ul
          [ Node.li [ Node.text "Item 1" ]
          ; Node.li [ Node.text "Item 2" ]
          ; Node.li [ Node.text "Item 3" ]
          ; Node.li [ Node.text "Item 4" ]
          ]
      ; st_button ~label:"Close Menu" ~set_state:set_opened ~state:Closed
      ]
;;

let menu_closed ~set_opened =
    let open MenuState in
    let open Vdom in
    Node.button
      ~attrs:
        [ Attr.on_click (fun _ -> set_opened Open); Attr.classes [ "menu-button-closed" ] ]
      [ Node.text "Open Menu" ]
;;

let menu_button =
    let module Mst = MenuState in
    let%sub state, set_state = Bonsai.state Mst.Closed in
    let%arr state = state and set_opened = set_state in
    if Mst.equal state Open then
      menu_opened ~set_opened
    else
      menu_closed ~set_opened
;;
