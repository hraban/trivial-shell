;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(in-package #:metashell)

(defgeneric file-to-string-as-lines (pathname)
  (:documentation ""))

(define-condition timeout-error (error)
                  ((command :initarg
                            :command :initform nil 
                            :reader timeout-error-command))
  (:report (lambda (c s)
	     (format s "Process timeout: command ~A" 
		     (timeout-error-command c)))))

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

(defun shell-command-with-timeout (command timeout on-timeout)
  (let ((process (create-shell-process command nil))
        (exit-code nil)
        (status nil))
    (process-wait-with-timeout
     "WAITING"
     (* *ticks-per-second* timeout)
     (lambda ()
       (setf (values status exit-code) (process-alive-p process))
       (values (not status))))
    (if status
      (funcall on-timeout)
      (values exit-code))))






#|

(sys:with-timeout (timeout 
                   (progn
                     (error 'timeout-error :command command)))
  (multiple-value-bind (output error status)
                       (excl.osi:command-output command :whole t)
    (values status)))

#+openmcl
(let ((process (ccl:run-program  
                "/bin/sh"
                (list "-c" command)
                :input nil 
                :output nil
                :error nil
                :wait nil))
      (status nil)
      (exit-code nil))
  (ccl:process-wait-with-timeout
   "WAITING"
   (* ccl:*ticks-per-second* timeout)
   (lambda ()
     (setf (values status exit-code) 
           (ccl:external-process-status process))
     (not (eq status :running))))
  (if (eq status :running)
    (progn
      (error 'timeout-error :command command))
    (values exit-code)))
|#