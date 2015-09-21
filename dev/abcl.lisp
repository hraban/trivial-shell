(in-package #:trivial-shell)

(defun %shell-command (command input)
  #+unix
  (with-input (input-stream (or input :none))
    (let (proc out-string err-string in-string out-stream err-stream in-stream)
      (setf proc (system:run-program *bourne-compatible-shell* (list "-c" command) :wait nil))
      (when input-stream
	(setf in-stream (system:process-input proc))
	(setf in-string (file-to-string-as-lines input-stream))
	;; on all UNIXen the line-ending character is of 1 byte length
	(write-string in-string in-stream :end (- (length in-string) 1))
	(close in-stream))
      (setf out-stream (system:process-output proc))
      (setf err-stream (system:process-error proc))
      (setf out-string (file-to-string-as-lines out-stream))
      (setf err-string (file-to-string-as-lines err-stream))
      (close out-stream)
      (close err-stream)
      (values out-string err-string (system:process-exit-code proc))))
  #+(not unix)
  (error 'unsupported-function-error :function 'shell-command))

(defun %os-process-id ()
  (error 'unsupported-function-error :function 'os-process-id))

(defun %get-env-var (name)
  (extensions:getenv name))

(defun %exit (code)
  (extensions:exit :status code))
