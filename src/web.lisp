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
  (let ((posts (get-all-blog-posts)))
    (render #P"index.html"
	    (list :posts posts))))

(defroute ("/create-post" :method :post) (&key _parsed)
  (create-blog-post (cdr (assoc "title" _parsed :test #'string=))
		    (cdr (assoc "content" _parsed :test #'string=)))
  (redirect "/"))


(defroute "/create-post-form" ()
  (render #P"create-post.html"))

(defroute "/about" ()
  (render #P"about.html"))

(defroute "/blog/:id" (&key id)
  (let ((post (get-blog-post id)))
    (render #P"blog.html" (list :post post))))

(defroute "/contact" ()
  (render #P"contact.html"))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
