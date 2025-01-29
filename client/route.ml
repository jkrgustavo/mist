open! Core

type t =
    | Home
    | Post of string
[@@deriving sexp, equal, compare]

let to_string exp = exp |> sexp_of_t |> Sexp.to_string
