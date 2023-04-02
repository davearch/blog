(in-package :cl-user)
(defpackage blog.view
  (:use :cl)
  (:import-from :blog.config
                :*template-directory*)
  (:import-from :caveman2
                :*response*
                :response-headers)
  (:import-from :djula
                :add-template-directory
                :compile-template*
                :render-template*
                :*djula-execute-package*
		:def-filter)
  (:import-from :datafly
                :encode-json)
  (:export :render
           :render-json))
(in-package :blog.view)

(djula:add-template-directory *template-directory*)

(defparameter *template-registry* (make-hash-table :test 'equal))

(defun render (template-path &optional env)
  (let ((template (gethash template-path *template-registry*)))
    (unless template
      (setf template (djula:compile-template* (princ-to-string template-path)))
      (setf (gethash template-path *template-registry*) template))
    (apply #'djula:render-template*
           template nil
           env)))

;; (def-filter :format-datetime (datetime-string &optional (format-string "%Y-%m-%d %H-:%M:%S"))
;;   (let ((dt (local-time:parse-timestring datetime-string)))
;;     (local-time:format-timestring nil dt format-string)))

;;; probably a better way to do this but i'm a n00b
(def-filter :format-date (created-at-string)
  (format-blog-date created-at-string))

(defun format-blog-date (date-string)
  (let ((date-components (split-sequence:split-sequence #\Space date-string)))
    (first date-components)))

(defun render-json (object)
  (setf (getf (response-headers *response*) :content-type) "application/json")
  (encode-json object))

;;
;; Execute package definition

(defpackage blog.djula
  (:use :cl)
  (:import-from :blog.config
                :config
                :appenv
                :developmentp
                :productionp)
  (:import-from :caveman2
                :url-for))

(setf djula:*djula-execute-package* (find-package :blog.djula))
