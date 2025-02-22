open Utils

[@react.component]
let make = () => {
    let (splash, setSplash) = React.useState(() => None);

    React.useEffect0(() => {
        module Prom = Js.Promise

        Fetch.fetch_text(~url="static/splash.txt")
        |> Prom.then_(res => {
            switch (res) {
            | Ok(txt) => setSplash(_ => Some(txt))
            | Error(e) => Js.log("ERROR: " ++ e)
            } |> Prom.resolve

        }) |> ignore;

        None
    });

    open Shadcn;

    <div className="homepage">
        <h1 className="text-red-500">{React.string("Hello world!")}</h1>
        <Button variant="default" size="sm">{React.string("Click Me!!")}</Button>

        { // Splash screen
            switch (splash) {
            | Some(s) => <pre>{React.string(s)}</pre>
            | None => <p>{React.string("Loading...")}</p> }
        }
    </div>
}
