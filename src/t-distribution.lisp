;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; Student's T distribution

(declaim (inline t-scale-to-variance-coefficient))
(defun t-scale-to-variance-coefficient (nu)
  "Return the coefficient that multiplies the Sigma matrix or the squared
scale to get the variance of a (multivariate) Student-T distribution.  Also
checks that nu > 2, ie the variance is defined."
  (assert (< 2d0 nu))
  (/ nu (- nu 2d0)))

(defun draw-standard-t (nu &key (rng *random-state*))
  "Draw a standard T random variate, with NU degrees of freedom."
  ;; !! algorithm from Bailey (1994), test Marsaglia (1984) to see if it is
  ;; !! faster
  (declare (internal-float nu)
           (optimize (speed 3))
           #+sbcl (sb-ext:muffle-conditions sb-ext:compiler-note))
  (try ((v1 (1- (next 2d0 rng)))
        (v2 (1- (next 2d0 rng)))
        (r-square (+ (expt v1 2) (expt v2 2))))
       (<= r-square 1)
       (* v1 (sqrt (the (internal-float 0d0)
                     (/ (* nu (1- (expt r-square (/ -2d0 nu)))) r-square))))))

(define-rv r-t (mean scale nu)
  (:documentation "T(mean,scale,nu) random variate."
   :include r-univariate)
  ((mean :type internal-float :reader t)
   (scale :type internal-float :reader t)
   (nu :type internal-float :reader t))
  (with-floats (mean scale nu)
    (assert (plusp nu))
    (assert (plusp scale))
    (make :mean mean :scale scale :nu nu))
  (variance ()
            (* (expt scale 2)
               (t-scale-to-variance-coefficient nu)))
  (draw (&key (rng *random-state*))
        (from-standard-normal (draw-standard-t nu :rng rng) mean scale)))
