(in-package #:trivial-shell)

(defun %shell-command (command input)
  (with-input (input-stream (or input :none))
    (let* ((process (sb-ext:run-program
		     *bourne-compatible-shell*
		     (list "-c" command)
		     :input input-stream :output :stream :error :stream))
	   (output (file-to-string-as-lines (sb-impl::process-output process)))
	   (error (file-to-string-as-lines (sb-impl::process-error process))))
      (close (sb-impl::process-output process))
      (close (sb-impl::process-error process))
      (values
       output
       error
       (sb-impl::process-exit-code process)))))

(defun create-shell-process (command wait)
  (sb-ext:run-program
   *bourne-compatible-shell*
   (list "-c" command)
   :input nil :output :stream :error :stream :wait wait))

(defun process-alive-p (process)
  (sb-ext:process-alive-p process))

(defun process-exit-code (process)
  (sb-ext:process-exit-code process))