(in-package #:trivial-shell)

(defun shell-command (command)
  (let* ((process (ext:run-program
                   *shell-path*
                   (list "-c" command)
                   :input nil :output :stream :error :stream))
         (output (file-to-string-as-lines (ext::process-output process)))
         (error (file-to-string-as-lines (ext::process-error process))))
    (close (ext::process-output process))
    (close (ext::process-error process))
    
    (values
     output
     error
     (ext::process-exit-code process))))
