open Utils;
open Lib;

module Article_page = {
    
    [@react.component]
    let make = (~path, ~content) => {
        <div>
            <h1>{ React.string("This is an article!") }</h1>
            <h3>{ React.string("Article title: " ++ path) }</h3>
            <div>{ ParseHtml.parse_to_array(content) |> React.array }</div>
        </div>
    };

};

module Index_page = {
    [@react.component]
    let make = (~path, ~dir) => {
        
        <div>
            <h1>{ React.string("Index page! Title: " ++ Filename.basename(path)) }</h1>
            <h4>{ React.string("Children:") }</h4>
            <ul>{
                List.map(ch => {<li>{ React.string(ch)}</li> }, dir) 
                |> Array.of_list 
                |> React.array
            }</ul>
        </div>
    }
};


[@react.component]
let make = (~url) => {

    let (article, setArticle) = React.useState(() => None);

    React.useEffect0(() => {
        module Prom = Js.Promise

        Fetch.fetch_text(~url)
        |> Prom.then_(res => {
            switch (res) {
            | Error(e) => Js.log("ERROR: " ++ e)
            | Ok(txt) => 
                switch (Psexp.deserialize(txt)) {
                | Ok(v) => setArticle(_ => Some(v))
                | Error(e) => Js.log("ERROR: " ++ e)
                }
            } |> Prom.resolve
        }) |> ignore;

        None
    });

    switch (article) {
    | None => <h1>{ React.string("Loading...") }</h1>
    | Some(cont) => 
        switch (cont) {
        | Page({path, content}) => <Article_page path content />
        | Index({path, children}) => <Index_page path dir=children />
        }
    };
}

