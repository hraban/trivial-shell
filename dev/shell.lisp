;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(in-package #:metashell)

(defun shell-command (command)
  "Synchronously execute the result using a Bourne-compatible shell,
returns (VALUES output error-output exit-status)"
  #+sbcl
  (let* ((process (sb-ext:run-program
                   *shell-path*
                   (list "-c" command)
                   :input nil :output :stream :error :stream))
         (output (read-stream-to-string (sb-impl::process-output process)))
         (error (read-stream-to-string (sb-impl::process-error process))))
    (close (sb-impl::process-output process))
    (close (sb-impl::process-error process))
    (values
     output
     error
     (sb-impl::process-exit-code process)))
  
  
  #+(or cmu scl)
  (let* ((process (ext:run-program
                   *shell-path*
                   (list "-c" command)
                   :input nil :output :stream :error :stream))
         (output (read-stream-to-string (ext::process-output process)))
         (error (read-stream-to-string (ext::process-error process))))
    (close (ext::process-output process))
    (close (ext::process-error process))
    
    (values
     output
     error
     (ext::process-exit-code process)))
  
  #+allegro
  (multiple-value-bind (output error status)
	               (excl.osi:command-output command :whole t)
    (values output error status))
  
  #+lispworks
  ;; BUG: Lispworks combines output and error streams
  (let ((output (make-string-output-stream)))
    (unwind-protect
      (let ((status
             (system:call-system-showing-output
              command
              :prefix ""
              :show-cmd nil
              :output-stream output)))
        (values (get-output-stream-string output) nil status))
      (close output)))
  
  #+clisp
  ;; BUG: CLisp doesn't allow output to user-specified stream
  (values
   nil
   nil
   (ext:run-shell-command  command :output :terminal :wait t))
  
  #+openmcl
  (let* ((process (ccl:run-program
                   *shell-path*
                   (list "-c" command)
                   :input nil :output :stream :error :stream
                   :wait t))
         (output (read-stream-to-string (ccl::external-process-output-stream process)))
         (error (read-stream-to-string (ccl::external-process-error-stream process))))
    (close (ccl::external-process-output-stream process))
    (close (ccl::external-process-error-stream process))
    (values output
            error
            (nth-value 1 (ccl::external-process-status process))))
  
  #+digitool
  (ccl:do-shell-script command)
  
  #-(or openmcl clisp lispworks allegro scl cmu sbcl digitool)
  (error "shell-command not implemented for this Lisp")
  )





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