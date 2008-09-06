(in-package #:common-lisp-user)

(unless (find-package '#:com.metabang.trivial-timeout)
(defpackage #:com.metabang.trivial-timeout
  (:use #:common-lisp)
  (:nicknames #:trivial-timeout)
  (:export 
   #:with-timeout
   #:timeout-error
   #:timeout-error-command)))
