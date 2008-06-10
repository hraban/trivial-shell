(in-package #:metashell)

(defparameter *bourne-compatible-shell* "/bin/sh"
  "The path to a Bourne compatible command shell in physical pathname notation.")

(defvar *shell-search-paths* '("/usr/bin/" "/usr/local/bin"))

(defparameter *ticks-per-second*
  #+(or openmcl ccl)
  ccl:*ticks-per-second*
  #+digitool
  60
  #-(or digitool openmcl ccl)
  60)

