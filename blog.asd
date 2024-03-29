(ql:quickload :3bmd :local-nicknames '((:3bmd . "./3bmd")))

(defsystem "blog"
  :version "0.1.0"
  :author "<darchuletajr@gmail.com>"
  :license ""
  :depends-on ("clack"
               "lack"
               "caveman2"
               "envy"
               "cl-ppcre"
               "uiop"
	       "uuid"

	       ;; markdown parser
	       "3bmd"
	       "3bmd-ext-code-blocks"

               ;; for @route annotation
               "cl-syntax-annot"

               ;; HTML Template
               "djula"

               ;; for DB
               "datafly"
               "sxql")
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description "personal blog"
  :in-order-to ((test-op (test-op "blog-test"))))
