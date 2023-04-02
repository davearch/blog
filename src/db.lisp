(in-package :cl-user)
(defpackage blog.db
  (:use :cl :uuid)
  (:import-from :blog.config
                :config)
  (:import-from :datafly
                :*connection*
                :retrieve-one
		:retrieve-all
                :execute)
  (:import-from :cl-dbi
                :dbi-programming-error
                :connect-cached)
  (:import-from :sxql
                :from
		:select)
  (:export :connection-settings
           :db
           :with-connection
           :get-all-blog-posts
           :get-blog-post
           :create-blog-post))
(in-package :blog.db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))

(defclass blog-post ()
  ((id :type string :initform (generate-uuid) :reader id)
   (title :type string :initarg :title :accessor title)
   (content :type string :initarg :content :accessor content)
   (created-at :type timestamp :initform (local-time:now) :reader created-at)
   (url :type string :initform (generate-url-from-title (title self)) :reader url)))

(defun create-blog-post (title content)
  (with-connection (db)
    (execute
     (sxql:create-table (:blog-post :if-not-exists t)
	 ((id :type 'string
	      :primary-key t)
	  (title :type 'string
		 :not-null t)
	  (content :type 'text
		   :not-null t)
	  (created-at :type 'timestamp
		      :not-null t)
	  (url :type 'string
	       :not-null t))))
    (if (title-unique-p title)
	(progn
	  (let ((id (generate-uuid))
		 (created-at (local-time:now))
		 (url (generate-url-from-title title)))
	    (execute
	     (sxql:insert-into :blog-post
				(sxql:set= :id id
					   :title title
					   :content content
					   :created-at created-at
					   :url url)))))
	(error "dat title already exists yo!! make it unique playa."))))

(defun get-all-blog-posts ()
  (with-connection (db)
    (handler-case
	(retrieve-all
	 (select :*
	   (from :blog-post)))
      (dbi-programming-error (e)
	(list)))))

(defun generate-uuid ()
  (uuid:make-v4-uuid))

(defun generate-url-from-title (title)
  (let ((separator "-"))
    (string-join (mapcar #'string-downcase (split-sequence:split-sequence #\Space title)) separator)))

(defun string-join (strings separator)
  (reduce (lambda (a b) (concatenate 'string a separator b)) strings))

(defun title-unique-p (title)
  (let ((blog-posts (get-all-blog-posts)))
    (not (find title blog-posts :key #'get-blog-post-title :test #'string=))))

(defun get-blog-post-title (blog-post)
  (getf blog-post :title))

(defun get-blog-post (id)
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :blog-post)
       (sxql:where (:= :id id))))))
