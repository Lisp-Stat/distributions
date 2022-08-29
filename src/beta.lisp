;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; Beta distribution.

(define-rv r-beta (alpha beta)
  (:documentation "Beta(alpha,beta) distribution, with density proportional to x^(alpha-1)*(1-x)^(beta-1)."
   :include r-univariate)
  ((alpha :type internal-float :reader t)
   (beta :type internal-float :reader t))
  (with-floats (alpha beta)
    (assert (plusp alpha))
    (assert (plusp beta))
    (make :alpha alpha :beta beta))
  (mean () (/ alpha (+ alpha beta)))
  (variance () (let ((sum (+ alpha beta)))
                 (/ (* alpha beta) (* (expt sum 2) (1+ sum)))))
  (draw (&key (rng *random-state*))
        (let ((alpha (draw (r-gamma alpha 1) :rng rng))
              (beta (draw (r-gamma beta 1) :rng rng)))
          (/ alpha (+ alpha beta))))
  (quantile (q)
            (with-floats (q)
	      (cephes:incbi alpha beta q)))
              ;; (rmath:qbeta q alpha beta 1 0)))
  )

