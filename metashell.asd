#|

Author: Gary King

Code forked from Kevin Rosenberg's KMRCL 
|#

(defpackage :metashell-system (:use #:cl #:asdf))
(in-package :metashell-system)

(defsystem metashell
  :version "0.1"
  :author "Gary Warren King <gwking@metabang.com>"
  :maintainer "Gary Warren King <gwking@metabang.com>"
  :licence "MIT Style License"
  :description "OS and Implementation independent access to the shell"
  :components ((:module "dev"
		        :components ((:static-file "notes.text")
				     
                                     (:file "package")
                                     (:file "definitions"
                                            :depends-on ("package"))
                                     (:file "shell"
                                            :depends-on ("definitions"))
                                     
                                     #+DIGITOOL
                                     (:module "mcl"
                                              :components ((:file "eval-apple-script")))))
               
               (:module "website"
                        :components ((:module "source"
                                              :components ((:static-file "index.lml"))))))
  :depends-on ())

