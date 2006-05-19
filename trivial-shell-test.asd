#|

Author: Gary King
|#

(defpackage :trivial-shell-test-system (:use #:cl #:asdf))
(in-package :trivial-shell-test-system)

(defsystem trivial-shell-test
  :author "Gary Warren King <gwking@metabang.com>"
  :maintainer "Gary Warren King <gwking@metabang.com>"
  :licence "MIT Style License"
  :description "Tests for trivial-shell"
  :components ((:module "tests"
		        :components ((:file "tests"))))
  :in-order-to ((test-op (load-op trivial-shell-test)))
  :perform (test-op :after (op c)
                    (describe
                     (funcall 
                      (intern (symbol-name (read-from-string "run-tests")) :lift) 
                      :suite (intern 
                              (symbol-name (read-from-string "trivial-shell-test"))
                              :trivial-shell-test))))
  :depends-on (lift trivial-shell))

(defmethod operation-done-p 
           ((o test-op)
            (c (eql (find-system 'trivial-shell-test))))
  (values nil))

