type t =
    | Page({ path: string, content: string })
    | Index({ path: string, children: list(string) })

let sexp_of_t = (pg) => {
    open Sexp;

    switch (pg) {
    | Page({ path, content }) =>
        List([
            Atom("Page"),
            List([ Atom("path"),  Atom(path) ]),
            List([ Atom("content"), Atom(content) ])
        ])
    | Index({ path, children }) =>
        List([
            Atom("Index"),
            List([ Atom("path"),  Atom(path) ]),
            List([ Atom("children"), List(List.map(ch => { Atom(ch) }, children)) ])
        ])
    }
};

let ( let* ) = (r, f) => {
    switch (r) {
    | Ok(v) => f(v)
    | Error(e) => Error(e)
    };
};

let t_of_sexp = (sexp: Sexp.t): result(t, string) => {
    open Sexp;

    switch (sexp) {
    | List([ 
        Atom("Page"), 
        List([Atom("path"), Atom(path)]), 
        List([Atom("content"), Atom(content)])
      ]) => Ok(Page({path, content}))
    | List([ 
        Atom("Index"), 
        List([ Atom("path"), Atom(path) ]), 
        List([ Atom("content"), List(atm_children) ]) 
      ]) => 
        let rec process_children = (lst, acc) => {
            switch (lst) {
            | [] => Ok(acc)
            | [Atom(ch), ...xs] => process_children(xs, [ch, ...acc])
            | _ => Error("Unable to parse Index children")
            };
        };

            switch (process_children(atm_children, [])) {
            | Ok(ch) => Ok(Index({ path, children: ch }))
            | Error(e) => Error(e)
            }
    | _ => Error("Unable to parse top level sexp: " ++ Sexp.to_string(sexp));
    };
}
