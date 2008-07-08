;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(in-package #:metashell)

(defgeneric file-to-string-as-lines (pathname)
  (:documentation ""))

(setf (documentation 'shell-command 'function)
      "Synchronously execute the result using a Bourne-compatible shell,
returns (values output error-output exit-status).")

(defmethod file-to-string-as-lines ((pathname pathname))
  (with-open-file (stream pathname :direction :input)
    (file-to-string-as-lines stream)))

(defmethod file-to-string-as-lines ((stream stream))
  (with-output-to-string (s)
    (loop for line = (read-line stream nil :eof nil) 
	 until (eq line :eof) do
	 (princ line s)
	 (terpri s))))

(defun shell-command (command &key input)
  (let* ((pos-/ (position #\/ command))
	 (pos-space (position #\Space command))
	 (binary (subseq command 0 (or pos-space)))
	 (args (and pos-space (subseq command pos-space))))
    (when (or (not pos-/) (and pos-/ pos-space) (< pos-/ pos-space))
      ;; no slash in the command portion, try to find the command with
      ;; our path
      (setf binary
	    (or (loop for path in *shell-search-paths* do
		     (let ((full-binary (make-pathname :name binary
						       :defaults path))) 
		       (when (probe-file full-binary)
			 (return full-binary))))
		binary)))
    (multiple-value-bind (output error status)
	(%shell-command (format nil "~a~@[ ~a~]" binary args) input)
      (values output error status))))

(defun os-process-id ()
  (%os-process-id))

(defun get-env-var (name)
  (%get-env-var name))
