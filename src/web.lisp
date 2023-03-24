(in-package :cl-user)
(defpackage blog.web
  (:use :cl
        :caveman2
        :blog.config
        :blog.view
        :blog.db
        :datafly
        :sxql)
  (:export :*web*))
(in-package :blog.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (render #P"index.html"))

(defroute "/about" ()
  (render #P"about.html"))

(defroute "/blog" ()
  (render #P"blog.html"))

(defroute "/blog/:id" (id)
  (render #P"blog.html" :id id))

(defroute "/contact" ()
  (render #P"contact.html"))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
