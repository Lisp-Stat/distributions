;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; Rayleigh distribution.

(declaim (inline drawy-rayleigh))
(defun draw-rayleigh (scale &key (rng *random-state*))
  "Return a random variable from the Rayleigh(scale) distribution, where scale > 0 and
density x * exp(-x^2 / (2 scale^2)) / scale^2 for x>=0 and 0 for x<0."
  (let ((u (- 1d0 (next 1d0 rng)))) ;We need 1-u, to avoid u=0.
    (* scale (sqrt (* -2d0 (log u))))))

(define-rv r-rayleigh (scale)
  (:documentation "Rayleigh(scale) distribution with scale > 0 and density x * exp(-x^2 / (2 scale^2)) / scale^2 for x>=0 and 0 for x<0."
   :include r-univariate)
  ((scale :type internal-float :reader T))
  (with-floats (scale)
    (assert (plusp scale))
    (make :scale scale))
  (mean () (* scale (sqrt (/ PI 2))))
  (variance () (* 1/2 (- 4 PI) scale scale))
  (draw (&key (rng *random-state*))
	(draw-rayleigh scale :rng rng))
  (cdf (x)
       (if (<= x 0)
	   0
	   (- 1d0 (exp (/ (* x x) (* -2 scale scale)))))))
