(in-package #:trivial-shell)

(defun shell-command (command)
  (multiple-value-bind (output error status)
	               (excl.osi:command-output command :whole t)
    (values output error status)))