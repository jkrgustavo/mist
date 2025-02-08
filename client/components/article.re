open Utils

let deserialize = (str) => {
    open Page;

    let* sexp = Sexp.from_string(str);
    let* p = t_of_sexp(sexp);
    Ok(p)
};

let page_temp = (~path, ~content) => {
    <div>
        <h1>{ React.string("This is an article!") }</h1>
        <h3>{ React.string("Article title: " ++ path) }</h3>
        <p>{ React.string(content) }</p>
    </div>
};

[@react.component]
let make = (~go_home) => {

    let (article, setArticle) = React.useState(() => None);
    let url = "api/foo"


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
                | Page({path, content}) => page_temp(~path, ~content)
                | _ => <h1>{ React.string("OOP") }</h1>
                }
            };
        }
        <button onClick=go_home>{React.string("Go Home")}</button>
    </div>
}

