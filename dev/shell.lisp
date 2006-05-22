;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(in-package #:metashell)

(defgeneric file-to-string-as-lines (pathname)
  (:documentation ""))

(define-condition timeout-error (error)
                  ()
  (:report (lambda (c s)
	     (declare (ignore c))
	     (format s "Process timeout"))))

(defmacro with-timeout ((seconds) &body body)
  #+allegro
  `(progn
     (mp:with-timeout (,seconds) ,@body))
  #+cmu
  `(mp:with-timeout (,seconds) ,@body)
  #+sb-thread
  `(handler-case 
       (sb-ext:with-timeout ,seconds ,@body)
     (sb!ext::timeout (c)
       (cerror "Timeout" 'timeout-error)))
  #+openmcl
  (let ((checker-process (format nil "Checker ~S" (gensym)))
        (waiting-process (format nil "Waiter ~S" (gensym)))
	(result (gensym)))
    `(let* ((,result nil)
	    (p (ccl:process-run-function 
		,checker-process
		(lambda ()
		  (setf ,result ,@body))))) 
       (ccl:process-wait-with-timeout
        ,waiting-process
        (* ,seconds ccl:*ticks-per-second*)
        (lambda ()
          (not (ccl::process-active-p p)))) 
       (when (ccl::process-active-p p)
	 (ccl:process-kill p)
	 (cerror "Timeout" 'timeout-error))
       (values ,result)))
  #-(or allegro cmu sb-thread openmcl)
  `(progn ,@body))

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