(ql:quickload :blog)

(defpackage blog.app
  (:use :cl)
  (:import-from :lack.builder
                :builder)
  (:import-from :ppcre
                :scan
                :regex-replace)
  (:import-from :blog.web
                :*web*)
  (:import-from :blog.config
                :config
                :productionp
                :*static-directory*))
(in-package :blog.app)

(builder
 (:static
  :path (lambda (path)
          (if (ppcre:scan "^(?:/assets/|/images/|/css/|/js/|/robot\\.txt$|/favicon\\.ico$)" path)
              path
              nil))
  :root *static-directory*)
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace
       :output ,(getf (config) :error-log))
     nil)
 :session
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((datafly:*trace-sql* t))
           (funcall app env)))))
 *web*)
