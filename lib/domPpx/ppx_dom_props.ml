(* open Ppxlib *)
(* open Ast_builder.Default *)
(**)
(* (* List of common DOM props and their types *) *)
(* let dom_props ~loc = [ *)
(*   ("id", [%type: string option]); *)
(*   ("className", [%type: string option]); *)
(*   ("style", [%type: ReactDOM.Style.t option]); *)
(*   ("title", [%type: string option]); *)
(*   ("role", [%type: string option]); *)
(*   ("tabIndex", [%type: int option]); *)
(*    *)
(*   (* Event handlers *) *)
(*   ("onClick", [%type: (React.Event.Mouse.t -> unit) option]); *)
(*   ("onDoubleClick", [%type: (React.Event.Mouse.t -> unit) option]); *)
(*   ("onMouseDown", [%type: (React.Event.Mouse.t -> unit) option]); *)
(*   ("onMouseUp", [%type: (React.Event.Mouse.t -> unit) option]); *)
(*   ("onMouseEnter", [%type: (React.Event.Mouse.t -> unit) option]); *)
(*   ("onMouseLeave", [%type: (React.Event.Mouse.t -> unit) option]); *)
(*    *)
(*   (* Form events *) *)
(*   ("onChange", [%type: (React.Event.Form.t -> unit) option]); *)
(*   ("onInput", [%type: (React.Event.Form.t -> unit) option]); *)
(*   ("onSubmit", [%type: (React.Event.Form.t -> unit) option]); *)
(*    *)
(*   (* Focus events *) *)
(*   ("onFocus", [%type: (React.Event.Focus.t -> unit) option]); *)
(*   ("onBlur", [%type: (React.Event.Focus.t -> unit) option]); *)
(*    *)
(*   (* Keyboard events *) *)
(*   ("onKeyDown", [%type: (React.Event.Keyboard.t -> unit) option]); *)
(*   ("onKeyUp", [%type: (React.Event.Keyboard.t -> unit) option]); *)
(*    *)
(*   (* ARIA attributes *) *)
(*   ("ariaLabel", [%type: string option]); *)
(*   ("ariaHidden", [%type: bool option]); *)
(*   ("ariaDisabled", [%type: bool option]); *)
(* ] *)
(**)
(* (* Add DOM props to a record type declaration *) *)
(* let add_dom_props_to_record_type ~loc fields = *)
(*   let existing_names = List.map (fun field -> field.pld_name.txt) fields in *)
(*    *)
(*   (* Create new fields for DOM props not already present *) *)
(*   let new_fields = List.filter_map (fun (name, typ) -> *)
(*     if List.mem name existing_names then None *)
(*     else  *)
(*       (* Create a field declaration with proper location info *) *)
(*       Some (label_declaration ~loc *)
(*              ~name:(Located.mk ~loc name) *)
(*              ~mutable_:Immutable *)
(*              ~type_:typ) *)
(*   ) (dom_props ~loc) in *)
(*    *)
(*   fields @ new_fields *)
(**)
(* (* Helper: Check if a binding is the make function *) *)
(* let is_make_binding binding = *)
(*   match binding.pvb_pat.ppat_desc with *)
(*   | Ppat_var { txt = "make"; _ } -> true *)
(*   | _ -> false *)
(**)
(* (* Helper: Add DOM props to function parameters *) *)
(* let add_dom_props_to_function ~loc expr = *)
(*   let rec process_fun expr processed_props = *)
(*     match expr.pexp_desc with *)
(*     | Pexp_fun (label, default, pat, body) -> *)
(*         (* Get parameter name if labeled *) *)
(*         let param_name = match label with *)
(*           | Labelled name | Optional name -> Some name *)
(*           | Nolabel -> None *)
(*         in *)
(*          *)
(*         (* Process the function body *) *)
(*         let new_body, all_processed_props =  *)
(*           process_fun body (match param_name with Some n -> n :: processed_props | None -> processed_props) *)
(*         in *)
(*          *)
(*         (* Reconstruct the function with updated body *) *)
(*         { expr with pexp_desc = Pexp_fun (label, default, pat, new_body) }, all_processed_props *)
(*          *)
(*     | _ -> *)
(*         (* We've reached the end of parameters - add DOM props *) *)
(*         let new_expr = List.fold_right (fun (name, _) acc -> *)
(*           if List.mem name processed_props then acc *)
(*           else *)
(*             let pat = pvar ~loc name in *)
(*             { acc with pexp_desc = Pexp_fun (Optional name, None, pat, acc) } *)
(*         ) (dom_props ~loc) expr in *)
(*          *)
(*         new_expr, processed_props *)
(*   in *)
(*    *)
(*   let new_expr, _ = process_fun expr [] in *)
(*   new_expr *)
(**)
(* (* Helper: Add DOM props to createElement record *) *)
(* (* Helper: Add DOM props to createElement record *) *)
(* let add_dom_props_to_createElement ~loc:_ expr = *)
(*   let rec process expr = *)
(*     match expr.pexp_desc with *)
(*     | Pexp_apply (fn, args) -> *)
(*         (* Check if this is React.createElement *) *)
(*         let is_createElement = match fn.pexp_desc with *)
(*           | Pexp_ident { txt = Lident "React.createElement" | Ldot (Lident "React", "createElement"); _ } -> true *)
(*           | _ -> false *)
(*         in *)
(*          *)
(*         if is_createElement && List.length args >= 2 then *)
(*           (* This is React.createElement - modify props record *) *)
(*           let component_arg = List.hd args in *)
(*           let props_arg = List.nth args 1 in *)
(*            *)
(*           match props_arg with *)
(*           | (Nolabel, ({ pexp_desc = Pexp_record (fields, None); pexp_loc; _ } as props_expr)) -> *)
(*               (* Add DOM props to the record *) *)
(*               let existing_names = List.map (fun (lid, _) ->  *)
(*                 match lid.txt with  *)
(*                 | Lident name -> name  *)
(*                 | _ -> "" *)
(*               ) fields in *)
(*                *)
(*               let dom_prop_fields = List.filter_map (fun (name, _) -> *)
(*                 if List.mem name existing_names then None *)
(*                 else  *)
(*                   (* Create field: name = name *) *)
(*                   Some ( *)
(*                     (Located.mk ~loc:pexp_loc (Lident name),  *)
(*                      evar ~loc:pexp_loc name) *)
(*                   ) *)
(*               ) (dom_props ~loc:pexp_loc) in *)
(*                *)
(*               let new_props_expr = { props_expr with pexp_desc = Pexp_record (fields @ dom_prop_fields, None) } in *)
(*               { expr with pexp_desc = Pexp_apply (fn, [(fst component_arg, snd component_arg); (Nolabel, new_props_expr)]) } *)
(*            *)
(*           | _ ->  *)
(*               (* Just process args recursively *) *)
(*               let new_args = List.map (fun (label, arg) -> (label, process arg)) args in *)
(*               { expr with pexp_desc = Pexp_apply (fn, new_args) } *)
(*         else *)
(*           (* Not React.createElement - process arguments recursively *) *)
(*           let new_args = List.map (fun (label, arg) -> (label, process arg)) args in *)
(*           { expr with pexp_desc = Pexp_apply (fn, new_args) } *)
(*      *)
(*     | Pexp_fun (label, default, pat, body) -> *)
(*         (* Process function body *) *)
(*         let new_body = process body in *)
(*         { expr with pexp_desc = Pexp_fun (label, default, pat, new_body) } *)
(*      *)
(*     | Pexp_let (rec_flag, bindings, body) -> *)
(*         (* Process let bindings and body *) *)
(*         let new_bindings = List.map (fun binding ->  *)
(*           { binding with pvb_expr = process binding.pvb_expr } *)
(*         ) bindings in *)
(*         let new_body = process body in *)
(*         { expr with pexp_desc = Pexp_let (rec_flag, new_bindings, new_body) } *)
(*      *)
(*     | _ -> expr *)
(*   in *)
(*    *)
(*   process expr *)
(**)
(* (* Main DOM props extension function *) *)
(* let dom_props_extension ~loc:_ ~path:_ structure = *)
(*   let modified_structure = ref [] in *)
(*    *)
(*   (* Process each structure item *) *)
(*   List.iter (fun item -> *)
(*     match item.pstr_desc with *)
(*     | Pstr_type (rec_flag, type_declarations) -> *)
(*         (* Look for props type *) *)
(*         let modified_types = List.map (fun type_decl -> *)
(*           let is_props =  *)
(*             String.ends_with ~suffix:"props" (String.lowercase_ascii type_decl.ptype_name.txt) || *)
(*             String.lowercase_ascii type_decl.ptype_name.txt = "props" *)
(*           in *)
(*            *)
(*           if is_props then *)
(*             match type_decl.ptype_kind with *)
(*             | Ptype_record fields -> *)
(*                 (* Add DOM props to record type *) *)
(*                 let new_fields = add_dom_props_to_record_type ~loc:type_decl.ptype_loc fields in *)
(*                 { type_decl with ptype_kind = Ptype_record new_fields } *)
(*             | _ -> type_decl *)
(*           else *)
(*             type_decl *)
(*         ) type_declarations in *)
(*          *)
(*         modified_structure := { item with pstr_desc = Pstr_type (rec_flag, modified_types) } :: !modified_structure *)
(*      *)
(*     | Pstr_value (rec_flag, bindings) -> *)
(*         (* Look for make function *) *)
(*         let modified_bindings = List.map (fun binding -> *)
(*           if is_make_binding binding then *)
(*             (* Add DOM props to make function *) *)
(*             let new_expr = binding.pvb_expr |>  *)
(*                           add_dom_props_to_function ~loc:binding.pvb_loc |> *)
(*                           add_dom_props_to_createElement ~loc:binding.pvb_loc *)
(*             in *)
(*             { binding with pvb_expr = new_expr } *)
(*           else *)
(*             binding *)
(*         ) bindings in *)
(*          *)
(*         modified_structure := { item with pstr_desc = Pstr_value (rec_flag, modified_bindings) } :: !modified_structure *)
(*      *)
(*     | _ -> *)
(*         modified_structure := item :: !modified_structure *)
(*   ) structure; *)
(*    *)
(*   (* Process the React.component transformed code *) *)
(*   let modified_structure = List.rev !modified_structure in *)
(*    *)
(*   (* Additional pass to process React.component transformed code *) *)
(*   let final_structure = ref [] in *)
(*    *)
(*   List.iter (fun item -> *)
(*     match item.pstr_desc with *)
(*     | Pstr_value (rec_flag, bindings) -> *)
(*         let processed_bindings = List.map (fun binding -> *)
(*           (* Check if this is a React.component transformed make function *) *)
(*           let is_transformed_make =  *)
(*             match binding.pvb_pat.ppat_desc with *)
(*             | Ppat_var { txt = "make"; _ } -> true *)
(*             | _ -> false *)
(*           in *)
(*            *)
(*           if is_transformed_make then *)
(*             (* Look for props in the function body and try to add DOM props *) *)
(*             let modified_expr =  *)
(*               match binding.pvb_expr.pexp_desc with *)
(*               | Pexp_apply (fn, args) -> *)
(*                   (* Add DOM props to args *) *)
(*                   let dom_args = List.map (fun (name, _) -> *)
(*                     (Optional name, evar ~loc:binding.pvb_expr.pexp_loc name) *)
(*                   ) (dom_props ~loc:binding.pvb_expr.pexp_loc) in *)
(*                    *)
(*                   { binding.pvb_expr with pexp_desc = Pexp_apply (fn, args @ dom_args) } *)
(*               | _ -> binding.pvb_expr *)
(*             in *)
(*              *)
(*             { binding with pvb_expr = modified_expr } *)
(*           else *)
(*             binding *)
(*         ) bindings in *)
(*          *)
(*         final_structure := { item with pstr_desc = Pstr_value (rec_flag, processed_bindings) } :: !final_structure *)
(*      *)
(*     | _ -> *)
(*         final_structure := item :: !final_structure *)
(*   ) modified_structure; *)
(*    *)
(*   List.rev !final_structure *)
(**)
(* (* Helper: Check for [@dom_props] attribute *) *)
(* let has_dom_props_attribute attributes = *)
(*   List.exists (fun attr -> attr.attr_name.txt = "dom_props") attributes *)
(**)
(* (* Process module bindings with [@dom_props] attribute *) *)
(* let rec process_module_expr expr = *)
(*   match expr.pmod_desc with *)
(*   | Pmod_structure structure -> *)
(*       (* Apply dom_props_extension to the structure *) *)
(*       let transformed_structure = dom_props_extension ~loc:expr.pmod_loc ~path:[] structure in *)
(*       { expr with pmod_desc = Pmod_structure transformed_structure } *)
(*    *)
(*   | Pmod_constraint (mod_expr, mod_type) -> *)
(*       let new_mod_expr = process_module_expr mod_expr in *)
(*       { expr with pmod_desc = Pmod_constraint (new_mod_expr, mod_type) } *)
(*    *)
(*   | Pmod_functor (param, mod_expr) -> *)
(*       let new_mod_expr = process_module_expr mod_expr in *)
(*       { expr with pmod_desc = Pmod_functor (param, new_mod_expr) } *)
(*    *)
(*   | _ -> expr *)
(**)
(* (* Main implementation function *) *)
(* let impl (structure : structure) : structure = *)
(*   let process_structure_item item = *)
(*     match item.pstr_desc with *)
(*     | Pstr_type (rec_flag, type_declarations) -> *)
(*         (* Process each type declaration *) *)
(*         let modified_types = List.map (fun type_decl -> *)
(*           if has_dom_props_attribute type_decl.ptype_attributes then *)
(*             match type_decl.ptype_kind with *)
(*             | Ptype_record fields -> *)
(*                 let new_fields = add_dom_props_to_record_type ~loc:type_decl.ptype_loc fields in *)
(*                 { type_decl with ptype_kind = Ptype_record new_fields } *)
(*             | _ -> type_decl (* Ignore non-record types *) *)
(*           else *)
(*             type_decl *)
(*         ) type_declarations in *)
(*         { item with pstr_desc = Pstr_type (rec_flag, modified_types) } *)
(**)
(*     | Pstr_value (rec_flag, bindings) -> *)
(*         (* Process each value binding *) *)
(*         let modified_bindings = List.map (fun binding -> *)
(*           if has_dom_props_attribute binding.pvb_attributes && is_make_binding binding then *)
(*             (* Modify the make function *) *)
(*             let new_expr = binding.pvb_expr *)
(*               |> add_dom_props_to_function ~loc:binding.pvb_loc *)
(*               |> add_dom_props_to_createElement ~loc:binding.pvb_loc in *)
(*             (* Add warning suppression attribute *) *)
(*             let warning_attr = attribute *)
(*               ~loc:binding.pvb_loc *)
(*               ~name:{txt = "ocaml.warning"; loc = binding.pvb_loc} *)
(*               ~payload:(PStr [pstr_eval ~loc:binding.pvb_loc (estring ~loc:binding.pvb_loc "-27") []]) *)
(*             in *)
(*             { binding with  *)
(*               pvb_expr = new_expr; *)
(*               pvb_attributes = warning_attr :: binding.pvb_attributes } *)
(*           else *)
(*             binding *)
(*         ) bindings in *)
(*         { item with pstr_desc = Pstr_value (rec_flag, modified_bindings) } *)
(**)
(*     | _ -> item (* Pass through other structure items unchanged *) *)
(*   in *)
(*   List.map process_structure_item structure *)
(**)
(* (* Register the transformation *) *)
(* let () = *)
(*   Driver.register_transformation "ppx_dom_props" ~impl *)
open Ppxlib
open Ast_builder.Default

(* List of common DOM props and their types *)
let dom_props ~loc = [
    ("id", [%type: string option]);
    ("className", [%type: string option]);
    ("style", [%type: ReactDOM.Style.t option]);
    ("title", [%type: string option]);
    ("role", [%type: string option]);
    ("tabIndex", [%type: int option]);

    (* Event handlers *)
    ("onClick", [%type: (React.Event.Mouse.t -> unit) option]);
    ("onDoubleClick", [%type: (React.Event.Mouse.t -> unit) option]);
    ("onMouseDown", [%type: (React.Event.Mouse.t -> unit) option]);
    ("onMouseUp", [%type: (React.Event.Mouse.t -> unit) option]);
    ("onMouseEnter", [%type: (React.Event.Mouse.t -> unit) option]);
    ("onMouseLeave", [%type: (React.Event.Mouse.t -> unit) option]);

    (* Form events *)
    ("onChange", [%type: (React.Event.Form.t -> unit) option]);
    ("onInput", [%type: (React.Event.Form.t -> unit) option]);
    ("onSubmit", [%type: (React.Event.Form.t -> unit) option]);

    (* Focus events *)
    ("onFocus", [%type: (React.Event.Focus.t -> unit) option]);
    ("onBlur", [%type: (React.Event.Focus.t -> unit) option]);

    (* Keyboard events *)
    ("onKeyDown", [%type: (React.Event.Keyboard.t -> unit) option]);
    ("onKeyUp", [%type: (React.Event.Keyboard.t -> unit) option]);

    (* ARIA attributes *)
    ("ariaLabel", [%type: string option]);
    ("ariaHidden", [%type: bool option]);
    ("ariaDisabled", [%type: bool option]);
]

(* Helper: Check for [@@dom_props] attribute *)
let has_dom_props_attribute attributes =
    List.exists (fun attr -> attr.attr_name.txt = "dom_props") attributes

(* Add DOM props to a record type declaration *)
let add_dom_props_to_record_type ~loc fields =
    let existing_names = List.map (fun field -> field.pld_name.txt) fields in

    (* Create new fields for DOM props not already present *)
    let new_fields = List.filter_map (fun (name, typ) ->
        if List.mem name existing_names then None
        else 
            (* Create a field declaration with proper location info *)
            Some (label_declaration ~loc
                ~name:(Located.mk ~loc name)
                ~mutable_:Immutable
                ~type_:typ)
    ) (dom_props ~loc) in

    fields @ new_fields

(* Helper: Add DOM props to function parameters *)
let add_dom_props_to_function ~loc expr =
    let rec process_fun expr processed_props =
        match expr.pexp_desc with
        | Pexp_fun (label, default, pat, body) ->
            (* Get parameter name if labeled *)
            let param_name = match label with
                | Labelled name | Optional name -> Some name
                | Nolabel -> None
            in

            (* Process the function body *)
            let new_body, all_processed_props = 
                process_fun body (match param_name with Some n -> n :: processed_props | None -> processed_props)
            in

            (* Reconstruct the function with updated body *)
            { expr with pexp_desc = Pexp_fun (label, default, pat, new_body) }, all_processed_props

        | _ ->
            (* We've reached the end of parameters - add DOM props *)
            let new_expr = List.fold_right (fun (name, _) acc ->
                if List.mem name processed_props then acc
                else
                    let pat = pvar ~loc name in
                    { acc with pexp_desc = Pexp_fun (Optional name, None, pat, acc) }
            ) (dom_props ~loc) expr in

            new_expr, processed_props
    in

    let new_expr, _ = process_fun expr [] in
    new_expr

(* Helper: Add DOM props to createElement record *)
let add_dom_props_to_createElement ~loc:_ expr =
    let rec process expr =
        match expr.pexp_desc with
        | Pexp_apply (fn, args) ->
            let is_createElement = match fn.pexp_desc with
                | Pexp_ident { txt = Lident "React.createElement" | Ldot (Lident "React", "createElement"); _ } -> true
                | _ -> false
            in

            if is_createElement && List.length args >= 2 then
                let _component_arg = List.hd args in
                let props_arg = List.nth args 1 in

                let new_props_arg = match props_arg with
                    | (label, ({ pexp_desc = Pexp_record (fields, None); pexp_loc; _ } as expr)) ->
                        let existing_names = List.map (fun (lid, _) -> 
                            match lid.txt with 
                            | Lident name -> name 
                            | _ -> ""
                        ) fields in

                        let dom_prop_fields = List.filter_map (fun (name, _) ->
                            if List.mem name existing_names then None
                            else 
                                Some (
                                    (Located.mk ~loc:pexp_loc (Lident name), 
                                        evar ~loc:pexp_loc name)
                                )
                        ) (dom_props ~loc:pexp_loc) in

                        let new_expr = { expr with pexp_desc = Pexp_record (fields @ dom_prop_fields, None) } in
                        (label, new_expr)
                    | _ -> props_arg         
                in

                let new_args = List.mapi (fun i arg ->
                    if i = 1 then new_props_arg else arg
                ) args in
                { expr with pexp_desc = Pexp_apply (fn, new_args) }
            else
                let new_args = List.map (fun (label, arg) -> (label, process arg)) args in
                { expr with pexp_desc = Pexp_apply (fn, new_args) }

        | Pexp_fun (label, default, pat, body) ->
            let new_body = process body in
            { expr with pexp_desc = Pexp_fun (label, default, pat, new_body) }

        | Pexp_let (rec_flag, bindings, body) ->
            let new_bindings = List.map (fun binding -> 
                { binding with pvb_expr = process binding.pvb_expr }
            ) bindings in
            let new_body = process body in
            { expr with pexp_desc = Pexp_let (rec_flag, new_bindings, new_body) }

        | _ -> expr
    in
    process expr

(* Process a type declaration with [@@dom_props] *)
let process_type_declaration type_decl =
    if has_dom_props_attribute type_decl.ptype_attributes then
        (* Remove the dom_props attribute *)
        let new_attributes = List.filter
            (fun attr -> attr.attr_name.txt <> "dom_props")
            type_decl.ptype_attributes in

        (* Process record type *)
        match type_decl.ptype_kind with
        | Ptype_record fields ->
            let new_fields = add_dom_props_to_record_type ~loc:type_decl.ptype_loc fields in
            { type_decl with 
                ptype_kind = Ptype_record new_fields;
                ptype_attributes = new_attributes }
        | _ -> 
            { type_decl with ptype_attributes = new_attributes }
    else
        type_decl

(* Process a value binding with [@@dom_props] *)
let process_value_binding binding =
    if has_dom_props_attribute binding.pvb_attributes then
        (* Remove the dom_props attribute *)
        let new_attributes = List.filter
            (fun attr -> attr.attr_name.txt <> "dom_props")
            binding.pvb_attributes in

        (* Check if this is a function binding *)
        match binding.pvb_pat.ppat_desc with
        | Ppat_var { txt = "make"; _ } ->
            (* This is the make function - add DOM props *)
            let new_expr = binding.pvb_expr 
                |> add_dom_props_to_function ~loc:binding.pvb_loc
                |> add_dom_props_to_createElement ~loc:binding.pvb_loc in

            { binding with 
                pvb_expr = new_expr;
                pvb_attributes = new_attributes }
        | _ ->
            { binding with pvb_attributes = new_attributes }
    else
        binding

(* Main implementation function *)
let impl (structure : structure) : structure =
    let rec process_structure_item item =
        match item.pstr_desc with
        | Pstr_type (rec_flag, type_declarations) ->
            (* Process type declarations *)
            let new_type_declarations = List.map process_type_declaration type_declarations in
            { item with pstr_desc = Pstr_type (rec_flag, new_type_declarations) }

        | Pstr_value (rec_flag, bindings) ->
            (* Process value bindings *)
            let new_bindings = List.map process_value_binding bindings in
            { item with pstr_desc = Pstr_value (rec_flag, new_bindings) }

        | Pstr_module mb ->
            (* Process module bindings recursively *)
            let new_mb = process_module_binding mb in
            { item with pstr_desc = Pstr_module new_mb }

        | Pstr_recmodule mbs ->
            (* Process recursive module bindings *)
            let new_mbs = List.map process_module_binding mbs in
            { item with pstr_desc = Pstr_recmodule new_mbs }

        | _ -> item

    (* Helper to process module bindings *)
    and process_module_binding mb =
        match mb.pmb_expr.pmod_desc with
        | Pmod_structure structure ->
            (* Process the structure recursively *)
            let new_structure = List.map process_structure_item structure in
            { mb with pmb_expr = { mb.pmb_expr with pmod_desc = Pmod_structure new_structure } }
        | _ -> mb
    in

    List.map process_structure_item structure

(* Register the transformation *)
let () =
    Driver.register_transformation "ppx_dom_props" ~impl
