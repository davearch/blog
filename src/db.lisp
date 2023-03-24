(in-package :cl-user)
(defpackage blog.db
  (:use :cl)
  (:import-from :blog.config
                :config)
  (:import-from :datafly
                :*connection*)
  (:import-from :cl-dbi
                :connect-cached)
  (:export :connection-settings
           :db
           :with-connection))
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

;; (defun create-blog-post (title content date)
;;   (with-connection (db)
;;     (db:with-transaction (db)
;;       (let ((post (make-instance 'blog-post :title title
;;                                             :content content
;;                                             :date date)))
;;         (db:insert-records db :blog-posts (list post))))))

;; (defun update-blog-post (id title content date)
;;   (with-connection (db)
;;     (db:with-transaction (db)
;;       (let ((post (db:find-record db :blog-posts :id id)))
;;         (setf (title post) title
;;               (content post) content
;;               (date post) date)
;;         (db:update-record db :blog-posts post))))))
