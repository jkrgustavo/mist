module FsData = {
    let ( let* ) = Result.bind;

    type t =
        | F(string)
        | D({path: string, children: array(t)})

    let get_name = fun
        | F(n) => n
        | D({path, _}) => path;

    let rec deserialize_ = (sexp: Sexp.t): result(t, string) => {

        let rec deser_children = (childs: list(Sexp.t), accum: result(array(t), string)) => {
            switch (childs) {
            | [x, ...xs] => 
                let* fs = deserialize_(x);
                let* acc = accum;
                deser_children(xs, Ok(Array.concat([ [|fs|], acc ])))
            | [] => accum
            }
        };

        switch (sexp) {
        | List([ Atom("F"), Atom(path) ]) => Ok(F(path))
        | List([ Atom("D"), List([ Atom("path"), Atom(path) ]), List([ Atom("children"), List(lst)]) ]) =>
            let* children = deser_children(lst, Ok([||]));
            Ok(D({path, children}))
        | _ => Js.log2("ERROR: Unable to parse sexp: ", sexp); Error("Unable to parse sexp")
        };
    };

    let deserialize = (exp: string): result(t, string) => {
        let* ser = Sexp.from_string(exp);
        let* data = deserialize_(ser);
        Ok(data)
    };
};


module DropTree = {

    module type NodeType = {
        let make: ({. "fs": FsData.t }) => React.element;
        let makeProps: (~fs: FsData.t, ~key: string=?, unit) =>
            {. "fs": FsData.t };
    };

    module rec TreeNode: NodeType = {


        let mk_label = (fs: FsData.t, isOpen) => {
            switch (fs) {
            | F(nm) => <span>{Filename.basename(nm) |> React.string}</span>
            | D({path, _}) => 
                <>
                    <span className="droptree-toggle">{(isOpen ? "v " : "> ") |> React.string}</span>
                    <span>{Filename.basename(path) |> React.string}</span>
                </>
            };
        };


        [@react.component]
        let make = (~fs) => {
            let (isOpen, setOpen) = React.useState(() => false);

            <div className="droptree-node">
                <div className="droptree-label" onClick={_ => setOpen(old => !old)}>
                    {mk_label(fs, isOpen)}
                </div>
                {
                    switch (fs) {
                    | F(_) => <div></div>
                    | D({children, _}) =>
                        if (isOpen) {
                            <div className="droptree-children">
                            {Array.map(fs => {
                                    <TreeNode fs /> 
                                    }, children) |> React.array}
                            </div>
                        } else { <div/>}
                    }
                }
            </div>
        };

    }; 

    [@react.component]
    let make = (~fs: FsData.t) => {
        <TreeNode fs/>
    };

}


type menu_state = {
    active: bool,
    fs: FsData.t
};

[@react.component]
let make = (~get_article, ~go_home) => {
    let (state, setState) = React.useState(() => { active: false, fs: FsData.F("Uninitialized")} );

    React.useEffect0(() => {
        module Prom = Js.Promise;

        Utils.Fetch.fetch_text(~url="/fs")
        |> Prom.then_(res => {
            switch (res) {
            | Ok(exp) => 
                switch (FsData.deserialize(exp)) {
                | Ok(v) => setState(old => {...old, fs: v});
                | Error(e) => Js.log("ERROR: " ++ e)
                }
            | Error(e) => Js.log("ERROR: " ++ e)
            } |> Prom.resolve
        }) |> ignore;
    
        None
    });
    
    let toggle_menu = _ => setState(old => { ...old, active: !old.active });
    <>
        <button onClick=toggle_menu className="nav-toggle">{React.string("Open Menu")}</button>
        <nav className={state.active ? "navbar open" : "navbar" }>
            <div className="nav-content">
                <button onClick=go_home>{React.string("go home")}</button>
                <button onClick={_ => get_article("foo")}>{React.string("open 'foo'")}</button>
                <DropTree fs=state.fs />
            </div>
        </nav>
        { state.active ? <div className="nav-overlay" onClick=toggle_menu /> : <div />}
    </>

};




