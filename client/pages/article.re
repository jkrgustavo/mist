open Utils

module Page = {
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

}

let deserialize = (str) => {
    open Page;
    let ( let* ) = Result.bind;

    let* sexp = Sexp.from_string(str);
    let* p = t_of_sexp(sexp);
    Ok(p)
};

let page_template = (~path, ~content) => {
    <div>
        <h1>{ React.string("This is an article!") }</h1>
        <h3>{ React.string("Article title: " ++ path) }</h3>
        <div>{ ParseHtml.parse_to_array(content) |> React.array }</div>
    </div>
};

let index_template = (~path, ~children) => {
    <div>
        <h1>{ React.string("Index page! Title: " ++ Filename.basename(path)) }</h1>
        <h4>{ React.string("Children:") }</h4>
        <ul>
        {
            List.map(ch => {<li>{ React.string(ch)}</li> }, children) 
            |> Array.of_list 
            |> React.array
        }
        </ul>
    </div>
};

[@react.component]
let make = (~route) => {

    let (article, setArticle) = React.useState(() => None);
    let url = route


    React.useEffect0(() => {
        module Prom = Js.Promise

        Fetch.fetch_text(~url)
        |> Prom.then_(res => {

            switch (res) {
            | Ok(txt) => 
                switch (deserialize(txt)) {
                | Ok(v) => setArticle(_ => Some(v))
                | Error(e) => Js.log("ERROR: " ++ e)
                }
            | Error(e) => Js.log("ERROR: " ++ e)
            } |> Prom.resolve

        }) |> ignore;

        None
    });

    // TODO: Figure out how to use the html
    <div>
        {
            switch (article) {
            | None => <h1>{ React.string("Loading...") }</h1>
            | Some(cont) => 
                switch (cont) {
                | Page({path, content}) => page_template(~path, ~content)
                | Index({path, children}) => index_template(~path, ~children)
                }
            };
        }
    </div>
}

