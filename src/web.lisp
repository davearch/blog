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

(defroute "/about" ()
  (render #P"about.html"))

(defroute "/contact" ()
  (render #P"contact.html"))

(defroute ("/create-post" :method :post) (&key _parsed)
  (if (developmentp)
      (create-blog-post (cdr (assoc "title" _parsed :test #'string=))
			(cdr (assoc "content" _parsed :test #'string=)))
      (redirect "/")))

(defroute "/create-post-form" ()
  (if (developmentp)
      (render #P "create-post.html")
      (redirect "/")))

(defroute "/blog/:id" (&key id)
  (if (not (is-uuid-p id))
      (next-route)
      (let ((post (get-blog-post id)))
	(render #P"blog.html" (list :post post)))))

(defroute "/blog/:url" (&key url)
  (let ((post (get-blog-post-by-url url)))
    (handler-case
	(progn
	  (when (not post)
	    (error "Post not found"))
	  (render #P"blog.html" (list :post post)))
      (error (err)
	(setf (response-status *response*) 404)
	(format nil "Error: ~A" err)))))

(defroute "/edit-post/:id" (&key id)
  (if (developmentp)
      (if (not (is-uuid-p id))
	  (next-route)
	  (let ((post (get-blog-post id)))
	    (render #P"edit-post.html" (list :post))))
      (redirect "/")))

(defroute "/edit-post/:url" (&key url)
  (if (developmentp)
      (let ((post (get-blog-post-by-url url)))
	(handler-case
	    (progn
	      (when (not post)
		(error "Post not found"))
	      (render #P"edit-post.html" (list :post post)))
	  (error (err)
	    (setf (response-status *response*) 404)
	    (format nil "Error: ~A" err))))
      (redirect "/")))

(defroute ("/update-post" :method :post) (&key _parsed)
  (if (developmentp)
      (let ((id (cdr (assoc "id" _parsed :test #'string=)))
	    (title (cdr (assoc "title" _parsed :test #'string=)))
	    (content (cdr (assoc "content" _parsed :test #'string=))))
	(update-blog-post id title content)
	(redirect (format nil "/blog/~A" id)))
      (redirect "/")))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
