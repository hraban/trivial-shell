#|
Author: Gary King

See file COPYING for details
|#

(defsystem "trivial-shell-test"
  :author "Gary Warren King <gwking@metabang.com>"
  :maintainer "Gary Warren King <gwking@metabang.com>"
  :licence "MIT Style License"
  :description "Tests for trivial-shell"
  :components ((:module
		"setup"
		:pathname "tests/"
		:components
		((:file "package")
		 (:file "tests" :depends-on ("package"))))
	       (:module
		"tests"
		:depends-on ("setup")
		:components ((:file "test-timeout"))))
  :depends-on ("lift" "trivial-shell")
  :perform (test-op (o c) (symbol-call :lift '#:run-tests) :config :generic))
