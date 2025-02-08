type response;

external fetch_: string => Js.Promise.t(response) = "fetch";

/* Extract the text from the resoponse */
[@mel.send] external text: response => Js.Promise.t(string) = "text";

/* Whether an issue occured */
[@mel.get] external ok: response => bool = "ok";

/* Response status */
[@mel.get] external status: response => int = "status";

let fetch_text = (~url) => {
        let open Js.Promise


        fetch_(url)
        |> then_(resp => {
                if (!ok(resp)) {
                    resolve @@ Error("ERROR: " ++ string_of_int @@ status(resp))
                } else {
                    text(resp)
                    |> then_(txt => resolve @@ Ok(txt))
                }
        }) |> catch(err => {
            let error = Obj.magic(err);
            
            switch (Js.Exn.message(error)) {
                | Some(mess) => resolve @@ Error(mess)
                | None => resolve @@ Error("Unknown error")
            };
        })
    }
