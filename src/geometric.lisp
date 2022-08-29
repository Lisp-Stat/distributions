;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

;;; Geometric distribution

(declaim (inline draw-geometric))
(defun draw-geometric (p &key (rng *random-state*))
  "Return the number of Bernoulli trials, with probability of success P, that were needed to reach the first success. This is >= 1."
    (do ((trials 1 (1+ trials)))
	((draw-bernoulli p :rng rng) trials)))

(define-rv r-geometric (pr)
  (:documentation "Geometric(pr) distribution."
   :include r-univariate)
  ((pr :type internal-float :reader T))
  (with-floats (pr)
    (check-probability pr :left)
    (make :pr pr))
  (mean () (/ pr))
  (variance () (/ (- 1 pr) (* pr pr)))
  (draw (&key (rng *random-state*))
	(draw-geometric pr :rng rng)))
