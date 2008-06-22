(in-package #:common-lisp-user)

(defpackage #:trivial-shell-test
  (:use #:common-lisp #:lift #:trivial-shell)
  (:shadowing-import-from #:lift #:with-timeout))
