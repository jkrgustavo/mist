type iconProps = {
    color: option(string),
    size: option(int),
    strokeWidth: option(int),
    className: option(string),
    onClick: option(React.Event.Mouse.t => unit),
};

module ArrowRight = {

    [@mel.module "lucide-react"]
    external icon: React.component(iconProps) = "ArrowRight";

    [@react.component]
    let make = (~color=?, ~size=?, ~strokeWidth=?, ~className=?, ~onClick=?) => {
        React.createElement(icon, {color, size, strokeWidth, className, onClick})
    };

};

module Mail = {

    [@mel.module "lucide-react"]
    external icon: React.component(iconProps) = "Mail";

    [@react.component]
    let make = (~color=?, ~size=?, ~strokeWidth=?, ~className=?, ~onClick=?) => {
        React.createElement(icon, {color, size, strokeWidth, className, onClick})
    };

};

module Github = {

    [@mel.module "lucide-react"]
    external icon: React.component(iconProps) = "Github";

    [@react.component]
    let make = (~color=?, ~size=?, ~strokeWidth=?, ~className=?, ~onClick=?) => {
        React.createElement(icon, {color, size, strokeWidth, className, onClick})
    };

};

module NotepadText = {

    [@mel.module "lucide-react"]
    external icon: React.component(iconProps) = "NotepadText";

    [@react.component]
    let make = (~color=?, ~size=?, ~strokeWidth=?, ~className=?, ~onClick=?) => {
        React.createElement(icon, {color, size, strokeWidth, className, onClick})
    };

};
