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
  (:import-from :djula
		:def-filter)
  (:export :connection-settings
           :db
           :with-connection
           :get-all-blog-posts
           :get-blog-post
           :create-blog-post
	   :get-blog-post-by-url
           :is-uuid-p
	   :update-blog-post))
   
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

(defun create-table-if-not-exists ()
  (sxql:create-table (:blog-post :if-not-exists t)
      ((id :type 'string
	   :primary-key t)
       (title :type 'string
	      :not-null t
	      :unique t)
       (content :type 'text
		:not-null t)
       (created-at :type 'timestamp
		   :not-null t)
       (url :type 'string
	    :not-null t))))

(defun create-blog-post (title content)
  (with-connection (db)
    (execute
     (create-table-if-not-exists))
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

(defun update-blog-post (id title content)
  (with-connection (db)
    (let ((post (get-blog-post id)))
      (when post
	(let ((url (generate-url-from-title title)))
	  (execute
	   (sxql:update :blog-post
			(sxql:set= :title title
			      :content content
			      :url url)
			(sxql:where (:= :id id)))))))))

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

(defun title-unique-p (title &optional id)
  (let ((blog-posts (get-all-blog-posts)))
    (not (find title blog-posts :key #'get-blog-post-title :test #'string=))))

(defun get-blog-post-id (blog-post)
  (getf blog-post :id))

(defun get-blog-post-title (blog-post)
  (getf blog-post :title))

(defun get-blog-post (id)
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :blog-post)
       (sxql:where (:= :id id))))))

(defun get-blog-post-by-url (url)
  (let ((blog-posts (get-all-blog-posts)))
    (find url blog-posts :key #'get-blog-post-url :test #'string=)))

(defun get-blog-post-url (blog-post)
  (getf blog-post :url))

(defun is-uuid-p (uuid-string)
  (let ((uuid-regex "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$"))
    (cl-ppcre:scan uuid-regex uuid-string)))

(def-filter :markdown->html (markdown)
  (let ((3bmd-code-blocks:*code-blocks* t))
    (with-output-to-string (s)
      (3bmd:parse-string-and-print-to-stream markdown s))))
