(defsystem "blog-test"
  :defsystem-depends-on ("prove-asdf")
  :author "<darchuletajr@gmail.com>"
  :license ""
  :depends-on ("blog"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "blog"))))
  :description "Test system for blog"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
