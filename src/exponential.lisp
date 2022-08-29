;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; Exponential distribution.
;;;
;;; Also provides the primitive draw-standard-exponential, which is useful for
;;; constructing other distributions.

(declaim (inline draw-standard-exponential draw-exponential))

(defun draw-standard-exponential (&key (rng *random-state*))
  "Return a random variable from the Exponential(1) distribution, which has density exp(-x) for x>=0 and 0 for x<0."
  ;; need 1-random, because there is a small but nonzero chance of getting a 0.
  (- (log (- 1d0 (next 1d0 rng)))))

(defun draw-exponential (rate &key (rng *random-state*))
  "Return a random variable from the Exponential(rate) distribution which has density rate*exp(-rate*x) for x>=0 and 0 for x<0. rate > 0."
  (/ (draw-standard-exponential :rng rng) rate))

(define-rv r-exponential (rate)
  (:documentation "Exponential(rate) distribution, with density rate*exp(-rate*x) for x>=0 and 0 for x<0. rate > 0."
   :include r-univariate)
  ((rate :type internal-float :reader t))
  (with-floats (rate)
    (assert (plusp rate))
    (make :rate rate))
  (mean () (/ rate))
  (variance () (expt rate -2))
  (log-pdf (x &optional ignore-constant?)
           (declare (ignore ignore-constant?))
           (with-floats (x)
             (- (log rate) (* rate x))))
  (cdf (x)
       (with-floats (x)
         (- 1 (exp (- (* rate x))))))
  (quantile (p)
            (with-floats (p)
              (check-probability p :right)
              (/ (log (- 1 p)) (- rate))))
  (draw (&key (rng *random-state*))
        (/ (draw-standard-exponential :rng rng) rate)))
