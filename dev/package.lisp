(in-package #:common-lisp-user)

(defpackage #:trivial-shell
  (:use #:common-lisp)
  (:nicknames #:metashell)
  (:export 
   #:shell-command
   
   ;; conditions
   #:timeout-error
   #:timeout-error-command))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import
   #+allegro 
   '(mp:process-wait-with-timeout)
   #+clisp
   '()
   #+(and cmu mp)
   '(mp:process-wait-with-timeout)
   #+(and cmu (not mp))
   '()
   #+cormanlisp
   '()
   #+digitool-mcl
   '(ccl:process-wait-with-timeout)
   #+(and ecl threads)
   '(mp:all-processes
     mp:process-name)
   #+(and ecl (not threads))
   '()
   #+lispworks
   '(mp:process-wait-with-timeout)
   #+openmcl
   '(ccl:process-wait-with-timeout)
   #+(and sbcl sb-threads)
   '(sb-threads:make-semaphore
     sb-threads:signal-semaphore)
   #+(and sbcl (not sb-threads))
   '()
   (find-package '#:trivial-shell)))
