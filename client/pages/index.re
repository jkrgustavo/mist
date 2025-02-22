
[@react.component]
let make = () => {
    open Utils.Route;
    open Components;

    let (route, setRoute) = React.useState(() => Home);

    let get_article = (r) => setRoute(_ => Article("/api/" ++ r));
    let go_home = _ => setRoute(_ => Home);

    <div className="bg-background">
        <MenuBar get_article go_home/>
        {
            switch (route) {
            | Home => <Landing />
            | Article(r) => <Article route=r/> } 
        }
    </div>
}
