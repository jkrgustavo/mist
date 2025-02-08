type response;

external fetch_: string => Js.Promise.t(response) = "fetch";

/* Extract the text from the resoponse */
[@mel.send] external text: response => Js.Promise.t(string) = "text";

/* Whether an issue occured */
[@mel.get] external ok: response => bool = "ok";

/* Response status */
[@mel.get] external status: response => int = "status";

let fetch_text: (~url:string) => Js.Promise.t(result(string, string));
