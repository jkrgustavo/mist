type t;

[@mel.module "dompurify"]
external domPurify: t = "default";

[@mel.send]
external sanitize: (t, string) => string = "sanitize";

let sanitizeHtml = (html: string): string => sanitize(domPurify, html);


[@mel.module "../js-bridges/parseHtml.js"]
external parse_to_array_: string => array(React.element) = "parse_to_array";

let parse_to_array = (html) => {
    sanitizeHtml(html) |> parse_to_array_
}

