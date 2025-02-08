(lang dune 3.17)
(using melange 0.1)

(name mist)

(generate_opam_files true)

(source
  (github  jkrgustavo/mist))

(authors "Gustavo Jokar jkrgustavo@gmail.com")

(maintainers "Gustavo Jokar jkrgustavo@gmail.com")

(package
 (name mist)
 (synopsis "Serve a directory of markdown files")
 (description "Serve a website that mirrors a directory of markdown files")
 (depends ocaml dream tyxml cmarkit))

; (dialect
;  (name mlx)
;  (implementation
;   (merlin_reader mlx)
;   (extension mlx)
;   (preprocess
;    (run mlx-pp %{input-file}))))
