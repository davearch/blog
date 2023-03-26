(in-package :cl-user)
(defpackage blog.db
  (:use :cl)
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
	   :get-all-blog-posts))
(in-package :blog.db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))

(defclass blog-post ()
  ((id :type integer :initarg :id :accessor id)
   (title :type string :initarg :title :accessor title)
   (content :type string :initarg :content :accessor content)
   (date :type date :initarg :date :accessor date)))

(defun create-blog-post (title content date)
  (with-connection (db)
    (execute
     (insert-into :blog-post
       (set= :title title
	     :content content
	     :date date)))))

(defun get-all-blog-posts ()
  (with-connection (db)
    (handler-case
	(retrieve-all
	 (select :*
	   (from :blog-post)))
      (dbi-programming-error (e)
	(list)))))
