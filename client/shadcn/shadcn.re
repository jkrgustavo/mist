module Button = {

    type buttonProps = {
        variant: option(string),
        size: option(string),
        onClick: option(React.Event.Mouse.t => unit),
        className: option(string),
        children: option(React.element),
        asChild: option(bool),
    };


    [@mel.module "@/components/button"]
    external button: React.component(buttonProps) = "Button";
    
    [@react.component]
    let make = (~variant=?, ~size=?, ~onClick=?, ~className=?, ~children=?, ~asChild=?) => {
        React.createElement(button, {variant, size, onClick, className, children, asChild});
    }
}

module Input = {

    type inputProps = {
        [@mel.as "type"] variant: string,
        className: option(string),
        children: option(React.element),
        placeHolder: option(string),
        id: option(string)
    };

    [@mel.module "@/components/input"]
    external input: React.component(inputProps) = "Input";

    [@react.component]
    let make = (~variant, ~className=?, ~children=?, ~placeHolder=?, ~id=?) => {
        React.createElement(input, {variant, className, children, placeHolder, id})
    };
    
}

module VInput = {

    type inputProps = {
        [@mel.as "type"] variant: string,
        className: option(string),
        children: option(React.element),
        placeHolder: option(string),
        id: option(string)
    };

    [@mel.module "@/components/input"]
    external input: React.component(inputProps) = "Input";

    [@react.component] 
    let make = (~variant, ~className=?, ~children=?, ~placeHolder=?, ~id=?) => {
        React.createElement(input, {variant, className, children, placeHolder, id})
    }; 

}

module Separator = {
    
    type separatorProps = {
        className: option(string),
        orientation: option(string),
        decorative: option(bool)
    };

    [@mel.module "@/components/separator"]
    external separator: React.component(separatorProps) = "Separator";

    [@react.component]
    let make = (~className=?, ~orientation=?, ~decorative=?) => {
        React.createElement(separator, {className, orientation, decorative})
    };

}



module Label = {
    type labelProps = {
        className: option(string),
        htmlFor: option(string),
        asChild: option(bool),
        children: option(React.element)
    };

    [@mel.module "@/components/label"]
    external label: React.component(labelProps) = "Label";

    [@react.component]
    let make = (~className=?, ~htmlFor=?, ~asChild=?, ~children=?) => {
        React.createElement(label, {className, htmlFor, asChild, children})
    };

}

module TabBar = {
    module Tabs = {
        type tabsProps = {
            asChild: option(bool),
            defaultValue: string,
            value: option(string),
            onValueChange: option(string => unit), 
            orientation: option(string),    // "horizontal" or "vertical" or None
            activationMode: option(string), // "manual" or "automatic"
            children: option(React.element),
            className: option(string),
        };

        [@mel.module "@/components/tablist.tsx"]
        external tabs: React.component(tabsProps) = "Tabs"

        [@react.component]
        let make = (
            ~asChild=?, 
            ~value=?, 
            ~onValueChange=?, 
            ~orientation=?, 
            ~activationMode=?, 
            ~children=?,
            ~className=?,
            ~defaultValue
        ) => {
            React.createElement(tabs, {
                asChild, 
                value, 
                onValueChange, 
                orientation, 
                activationMode, 
                defaultValue,
                className,
                children
            })

        }
    };

    module TabsList = {
        type tabsListProps = {
            asChild: option(bool),
            loop: option(bool),
            children: option(React.element),
            className: option(string),
        };

        [@mel.module "@/components/tablist.tsx"]
        external tabslist: React.component(tabsListProps) = "TabsList"

        [@react.component]
        let make = (~asChild=?, ~loop=?, ~className=?, ~children=?) => {
            React.createElement(tabslist, {asChild, loop, className, children})
        }
    };

    module TabsTrigger = {
        type tabstriggerProps = {
            asChild: option(bool),
            value: option(string),
            disabled: option(bool),
            children: option(React.element),
            className: option(string),
        };

        [@mel.module "@/components/tablist.tsx"]
        external tabstrigger: React.component(tabstriggerProps) = "TabsTrigger"

        [@react.component]
        let make = (~asChild=?, ~value=?, ~disabled=?, ~className=?, ~children=?) => {
            React.createElement(tabstrigger, {asChild, value, disabled, className, children})
        }
    };

    module TabsContent = {
        type tabsContentProps = {
            asChild: option(bool),
            value: option(string),
            forceMount: option(bool),
            children: option(React.element),
            className: option(string),
        };

        [@mel.module "@/components/tablist.tsx"]
        external tabscontent: React.component(tabsContentProps) = "TabsContent"

        [@react.component]
        let make = (~asChild=?, ~value=?, ~forceMount=?, ~className=?, ~children=?) => {
            React.createElement(tabscontent, {asChild, value, forceMount, className, children})
        }
    };

};

module Cards = {

    module Card = {
        type cardProps = {
            className: option(string),
            children: option(React.element),
            id: option(string),
        };

        [@mel.module "@/components/card"]
        external separator: React.component(cardProps) = "Card";

        [@react.component]
        let make = (~className=?, ~children=?, ~id=?) => {
            React.createElement(separator, {className, children, id})
        };
    };

    module CardHeader = {
        type cardProps = {
            className: option(string),
            children: option(React.element),
            id: option(string),
        };

        [@mel.module "@/components/card"]
        external separator: React.component(cardProps) = "CardHeader";

        [@react.component]
        let make = (~className=?, ~children=?, ~id=?) => {
            React.createElement(separator, {className, children, id})
        };
    };

    module CardTitle = {
        type cardProps = {
            className: option(string),
            children: option(React.element),
            id: option(string),
        };
        [@mel.module "@/components/card"]
            external separator: React.component(cardProps) = "CardTitle";
        [@react.component]
            let make = (~className=?, ~children=?, ~id=?) => {
                React.createElement(separator, {className, children, id})
            };
    };

    module CardDescription = {
        type cardProps = {
            className: option(string),
            children: option(React.element),
            id: option(string),
        };
        [@mel.module "@/components/card"]
            external separator: React.component(cardProps) = "CardDescription";
        [@react.component]
            let make = (~className=?, ~children=?, ~id=?) => {
                React.createElement(separator, {className, children, id})
            };
    };

    module CardContent = {
        type cardProps = {
            className: option(string),
            children: option(React.element),
            id: option(string),
        };
        [@mel.module "@/components/card"]
        external separator: React.component(cardProps) = "CardContent";

        [@react.component]
        let make = (~className=?, ~children=?, ~id=?) => {
            React.createElement(separator, {className, children, id})
        };
    };

    module CardFooter = {
        type cardProps = {
            className: option(string),
            children: option(React.element),
            id: option(string),
        };
        [@mel.module "@/components/card"]
        external separator: React.component(cardProps) = "CardFooter";

        [@react.component]
        let make = (~className=?, ~children=?, ~id=?) => {
            React.createElement(separator, {className, children, id})
        };
    };

};

