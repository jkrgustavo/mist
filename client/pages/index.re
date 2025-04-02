open Lib.Route;

let test_url = (~setRoute, url: ReasonReactRouter.url) => {

    switch (url.path) {
    | ["article", ..._] => setRoute(_ => Article("http://localhost:8080/fs/dir1"));
    | _ => setRoute(_ => Home)
    }
};



[@react.component]
let make = () => {

    let (route, setRoute) = React.useState(() => Home);
    let _ = ReasonReactRouter.watchUrl(test_url(~setRoute));

    <div className="bg-background">
        {
            switch (route) {
            | Home => <Landing />
            | Article(r) => <Article url=r/> } 
        }
    </div>
}
