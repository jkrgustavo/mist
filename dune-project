(lang dune 3.17)

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
 (depends ocaml dream tyxml omd))

