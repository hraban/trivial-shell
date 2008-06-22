#|
Author: Gary King

See file COPYING for details
|#

(defpackage #:trivial-shell-test-system (:use #:cl #:asdf))
(in-package #:trivial-shell-test-system)

(defsystem trivial-shell-test
  :author "Gary Warren King <gwking@metabang.com>"
  :maintainer "Gary Warren King <gwking@metabang.com>"
  :licence "MIT Style License"
  :description "Tests for trivial-shell"
  :components ((:module 
		"setup"
		:pathname "tests/"
		:components 
		((:file "package")))
	       (:module 
		"tests"
		:depends-on ("setup")
		:components ((:file "tests")
			     (:file "test-timeout"))))
  :depends-on (:lift :trivial-shell))


