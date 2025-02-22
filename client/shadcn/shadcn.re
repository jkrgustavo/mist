
module Button = {

    type buttonProps = {
        variant: string,
        size: string,
        onClick: option(React.Event.Mouse.t => unit),
        className: option(string),
        children: option(React.element),
    };


    [@mel.module "@/components/button/button"]
    external button: React.component(buttonProps) = "Button";
    
    [@react.component]
    let make = (~variant, ~size, ~onClick=?, ~className=?, ~children=?) => {
        React.createElement(button, {variant, size, onClick, className, children});
    }
}
