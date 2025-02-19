type route =
    | Home
    | Article(string)

let toggle_route = (r) => {
    switch (r) {
    | Home => Article("/api")
    | Article(_) => Home }
}
