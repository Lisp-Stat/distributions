;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: CL-USER -*-

(defpackage #:distributions-tests
  (:use #:cl
        #:fiveam
        #:num-utils.elementwise
        #:num-utils.matrix-shorthand
        #:num-utils.num=
        #:distributions
        #:let-plus)
  (:export
   #:run!
   #:all-tests))

