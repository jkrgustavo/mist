open Pages;


let () =
    switch (ReactDOM.querySelector("#root")) {
        | None =>
            Js.Console.error("Failed to start React: couldn't find the #root element")
        | Some(element) =>
            let root = ReactDOM.Client.createRoot(element);
            ReactDOM.Client.render(root, <Index />);
    }
