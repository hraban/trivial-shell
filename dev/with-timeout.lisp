(in-package #:common-lisp-user)

(defpackage #:com.metabang.trivial-timeout
  (:use #:common-lisp)
  (:nicknames #:trivial-timeout)
  (:export 
   #:with-timeout
   #:timeout-error
   #:timeout-error-command))

(in-package #:com.metabang.trivial-timeout)

#-:com.metabang.trivial-timeout
(define-condition timeout-error (error)
                  ()
  (:report (lambda (c s)
	     (declare (ignore c))
	     (format s "Process timeout"))))

#-:com.metabang.trivial-timeout
(defmacro with-timeout ((seconds) &body body)
  (let ((gseconds (gensym "seconds-"))
	#+(and sbcl (not sb-thread))
	(glabel (gensym "label-"))
	#+(and sbcl (not sb-thread))
	(gused-timer? (gensym "used-timer-")))
    `(let ((,gseconds ,seconds))
       (flet ((doit ()
		(progn ,@body)))
	 (cond (,gseconds
		#+allegro
		(mp:with-timeout (,gseconds (error 'timeout-error)) 
		  (doit))
		#+cmu
		(mp:with-timeout (,gseconds) (doit))
		#+(and sbcl sb-thread)
		(handler-case 
		    (sb-ext:with-timeout ,gseconds (doit))
		  (sb-ext::timeout (c)
		    (error 'timeout-error)))
		#+(and sbcl (not sb-thread))
		(let ((,gused-timer? nil))
		  (catch ',glabel
		    (sb-ext:schedule-timer
		     (sb-ext:make-timer (lambda ()
					  (setf ,gused-timer? t)
					  (throw ',glabel nil)))
		     ,gseconds)
		    (doit))
		  (when ,gused-timer?
		    (error 'timeout-error)))
		#+(or digitool openmcl ccl)
		,(let ((checker-process (format nil "Checker ~S" (gensym)))
		       (waiting-process (format nil "Waiter ~S" (gensym)))
		       (result (gensym))
		       (process (gensym)))
		      `(let* ((,result nil)
			      (,process (ccl:process-run-function 
					 ,checker-process
					 (lambda ()
					   (setf ,result (progn (doit))))))) 
			 (ccl:process-wait-with-timeout
			  ,waiting-process
			  (* ,gseconds #+(or openmcl ccl)
			     ccl:*ticks-per-second* #+digitool 60)
			  (lambda ()
			    (not (ccl::process-active-p ,process)))) 
			 (when (ccl::process-active-p ,process)
			   (ccl:process-kill ,process)
			   (cerror "Timeout" 'timeout-error))
			 (values ,result)))
		#-(or allegro cmu sb-thread openmcl ccl mcl digitool)
		(progn (doit)))
	       (t
		(doit)))))))

(pushnew :com.metabang.trivial-timeout *features*)