module Route = {
    type route =
        | Home
        | Article

    let toggle_route = (r) => {
        switch (r) {
        | Home => Article
        | Article => Home }
    }
}

[@react.component]
let make = () => {
    open Route;

    let (route, setRoute) = React.useState(() => Home);

    <>
        <button onClick={_ => setRoute(toggle_route)}>
            { React.string("Toggle route")}
        </button>
        {
            switch (route) {
            | Home => <Landing />
            | Article => <Article go_home={_ => setRoute(_ => Home)}/> }
        }
    </>
}
