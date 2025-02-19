import parse from "html-react-parser"

export function parse_to_array(html) {
    const parsed = parse(html);

    return Array.isArray(parsed) ? parsed : [parsed];
}
