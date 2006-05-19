(in-package #:metashell)

(defparameter *shell-path* "/bin/sh"
  "The path to a Bourne compatible command shell in physical pathname notation.")

(defparameter *ticks-per-second*
  #+openmcl
  ccl:*ticks-per-second*
  #+digitool
  60
  #-(or digitool openmcl)
  60)

