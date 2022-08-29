;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: CL-USER -*-
;;; Copyright (c) 2020 by Symbolics Pte. Ltd. All rights reserved
(in-package #:distributions)

;;; Lognormal distribution

(define-rv r-log-normal (log-mean log-sd)
  (:documentation "Log-normal distribution with location log-mean and scale log-sd."
   :include r-univariate)
  ((log-mean :type internal-float)
   (log-sd :type internal-float))
  (with-floats (log-mean log-sd)
    (assert (plusp log-sd))
    (make :log-mean log-mean :log-sd log-sd))
  (mean () (exp (+ log-mean (/ (expt log-sd 2) 2))))
  (variance () (let ((sigma^2 (expt log-sd 2)))
                 (* (1- (exp sigma^2))
                    (exp (+ (* 2 log-mean) sigma^2)))))
  (log-pdf (x &optional ignore-constant?)
           (maybe-ignore-constant ignore-constant?
                                  (with-floats (x)
                                    (let ((log-x (log x)))
                                      (- (/ (expt (- log-x log-mean) 2)
                                            (expt log-sd 2) -2)
                                         log-x)))
                                  (- +normal-log-pdf-constant+ (log log-sd))))
  (cdf (x)
       (if (plusp x)
           (cdf-normal% (log x) log-mean log-sd)
           0d0))
  (quantile (q)
            (check-probability q :right)
            (if (zerop q)
                0d0
                (exp (quantile-normal% q log-mean log-sd))))
  (draw (&key (rng *random-state*))
        (exp (from-standard-normal (draw-standard-normal :rng rng) log-mean log-sd))))
