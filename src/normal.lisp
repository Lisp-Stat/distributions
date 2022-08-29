;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

;;; Normal distribution (univariate).
;;;
;;; Also provides some primitives (mostly for standardized normal)
;;; that are useful for constructing/drawing from other distributions.

;(declaim (ftype (function () internal-float) draw-standard-normal))

(defun draw-standard-normal (&key (rng *random-state*))
  "Draw a random number from N(0,1)."
  ;; Method from Leva (1992).  This is considered much better/faster than the Box-Muller method.
  (declare (optimize (speed 3) (safety 0))
           #+sbcl (sb-ext:muffle-conditions sb-ext:compiler-note))
  (tagbody
   top
     (let* ((u (next 1d0 rng))
            (v (* 1.7156d0 (- (next 1d0 rng) 0.5d0)))
            (x (- u 0.449871d0))
            (y (+ (abs v) 0.386595d0))
            (q (+ (expt x 2) (* y (- (* 0.19600d0 y) (* 0.25472d0 x))))))
       (if (and (> q 0.27597d0)
                (or (> q 0.27846d0)
                    (plusp (+ (expt v 2) (* 4 (expt u 2) (log u))))))
           (go top)
           (return-from draw-standard-normal (/ v u))))))

(declaim (inline to-standard-normal from-standard-normal cdf-normal% quantile-normal%))

(defun to-standard-normal (x mu sigma)
  "Scale x to standard normal."
  (/ (- x mu) sigma))

(defun from-standard-normal (x mu sigma)
  "Scale x from standard normal."
  (+ (* x sigma) mu))

(defun cdf-normal% (x mu sigma)
  "Internal function for normal CDF."
  (with-floats (x)
    (/ (1+ (specfun:erf (/ (- x mu)
			   (* sigma (sqrt 2d0)))))
       2)))
;;    (rmath:pnorm5 x mean sd 1 0)))

(defun quantile-normal% (q mu sigma)
  "Internal function for normal quantile."
  (with-floats (q)
    (check-probability q :both)
    (+ mu (* sigma (sqrt 2d0) (specfun:inverse-erf (- (* 2 q) 1d0))))))
;;(rmath:qnorm5 q mean sd 1 0)))

;;; Not used; PDF calculated via log-pdf.
(defun pdf-normal% (x &key (mu 0) (sigma 1)) ; mu = mean, sigma = standard deviation
  "Direct calculation of the Probability Density of the normal distribution."
  (/ (exp (- (/ (expt (- x mu) 2)
                (* 2 (expt sigma 2)))))
     (* sigma (sqrt (* 2 pi)))))

(defconstant +normal-log-pdf-constant+ (as-float (/ (log (* 2 pi)) -2))
  "Normalizing constant for a standard normal PDF.")

(define-rv r-normal (&optional (mean 0d0) (variance 1d0))
  (:documentation "Normal(mean,variance) distribution."
   :include r-univariate)
  ((mean :type internal-float :reader t)
   (sd :type internal-float :reader t))
  (with-floats (mean variance)
    (assert (plusp variance))
    (make :mean mean :sd (sqrt variance)))
  (variance () (expt sd 2))
  (log-pdf (x &optional ignore-constant?)
           (maybe-ignore-constant ignore-constant?
                                  (with-floats (x)
                                    (/ (expt (- x mean) 2) (expt sd 2) -2d0))
                                  (- +normal-log-pdf-constant+ (log sd))))
  (cdf (x)      (cdf-normal% x mean sd))
  (quantile (q) (quantile-normal% q mean sd))
  (draw (&key (rng *random-state*))
        (from-standard-normal (draw-standard-normal :rng rng) mean sd)))

;;; !! It is claimed in Marsaglia & Tsang (2000) that the ziggurat
;;; method is about 5-6 times faster than the above, mainly because of
;;; precomputed tables.  Need to write and test this, and if it is
;;; true, use that method instead.
