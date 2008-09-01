(in-package #:trivial-shell)

(defun shell-command (command input)
  (when input
    (error "This version of trivial-shell does not support the input parameter."))
  (ccl:do-shell-script command))
