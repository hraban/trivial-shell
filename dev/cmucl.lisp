(in-package #:trivial-shell)

(defun shell-command (command)
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
     (ext::process-exit-code process))))
