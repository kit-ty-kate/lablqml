open Base
open Stdio
module C = Configurator.V1

let write_sexp fn sexp = Out_channel.write_all fn ~data:(Sexp.to_string sexp)

let () =
  C.main ~name:"mylib" (fun c ->
      let default : C.Pkg_config.package_conf = { libs = [ "-lblah" ]; cflags = [] } in
      let conf =
        match C.Pkg_config.get c with
        | None -> default
        | Some pc -> Option.value (C.Pkg_config.query pc ~package:"Qt5Quick") ~default
      in
      let check_which s =
        if Stdlib.Sys.command (Printf.sprintf "which %s-qt5" s) = 0
        then Printf.sprintf "%s-qt5" s
        else s
      in
      write_sexp "c_flags.sexp" (sexp_of_list sexp_of_string conf.cflags);
      write_sexp "c_library_flags.sexp" (sexp_of_list sexp_of_string conf.libs);
      write_sexp
        "ocaml_qt_libs.sexp"
        (sexp_of_list sexp_of_string
        @@ List.concat_map ~f:(fun s -> [ "-ccopt"; s ])
        @@ conf.libs);
      write_sexp "moc.sexp" (sexp_of_string @@ check_which "moc");
      write_sexp "rcc.sexp" (sexp_of_string @@ check_which "rcc"))
;;
