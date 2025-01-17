open! Core
open! Bonsai_web
open Bonsai.Let_syntax

module Route = struct
  type t =
      | Home
      | Post of string
  [@@deriving sexp, equal]

  let _to_string exp = exp |> sexp_of_t |> Sexp.to_string
end


let app =
    let%sub current_route, set_route = Bonsai.state Route.Home in
    let%sub menu = Menu.menu in
    let%sub home_page = Home_page.component ~_set_route:0 in
    let%arr _current_route = current_route 
    and _set_route = set_route 
    and menu = menu
    and home_page = home_page in
    Vdom.Node.div ~attrs:[ Vdom.Attr.classes [ "root" ] ] [ home_page; menu ]
;;

let () = Start.start app
(*
                                            ,:
                                          ,' |
                                         /() :
                                      --'   /
                                      \/ /:/
                                      / ://_\
                                   __/   /
                                   )'-. /
                                   ./  :\
                                    /.' '
                                  '/'
                                  +
                                 '
                               `.
                           .-"-
                          (    |
                       . .-'  '.
                      ( (.   )8:
                  .'    / (_  )
                   _. :(.   )8P  `
               .  (  `-' (  `.   .
                .  :  (   .a8a)
               /_`( "a `a. )"'
           (  (/  .  ' )=='
          (   (    )  .8"   +
            (`'8a.( _(   (
         ..-. `8P    ) `  )  +
       -'   (      -ab:  )
     '    _  `    (8P"Ya
   _(    (    )b  -`.  ) +
  ( 8)  ( _.aP" _a   \( \   *
+  )/    (8P   (88    )  )
   (a:f   "     `"`
*)
