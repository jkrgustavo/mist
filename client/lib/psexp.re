open Sexp;

type t = 
    | Page({ path: string, content: string })
    | Index({ path: string, children: list(string) })

let t_of_sexp = (sexp: Sexp.t): result(t, string) => {
    let rec process_children = (lst, acc) => {
        switch (lst) {
        | [] => Ok(acc)
        | [Atom(ch), ...xs] => process_children(xs, [ch, ...acc])
        | _ => Error("Unable to parse Index children")
        };
    };

    switch (sexp) {
    | List([ 
        Atom("Page"), 
        List([ Atom("path"), Atom(path) ]), 
        List([ Atom("content"), Atom(content) ])
      ]) => Ok(Page({path, content}))
    | List([ 
        Atom("Index"), 
        List([ Atom("path"), Atom(path) ]), 
        List([ Atom("children"), List(atm_children) ]) 
      ]) => 
        switch (process_children(atm_children, [])) {
        | Ok(ch) => Ok(Index({ path, children: ch }))
        | Error(e) => Error(e)
        }
    | _ => Error("Unable to parse top level sexp: " ++ to_string(sexp));
    };
}

let deserialize = (str) => {
    let ( let* ) = Result.bind;

    let* sexp = Sexp.from_string(str);
    let* p = t_of_sexp(sexp);
    Ok(p)
};
