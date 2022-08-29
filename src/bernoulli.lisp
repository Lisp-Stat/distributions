;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

;;; Bernoulli distribution

(declaim (inline draw-bernoulli draw-bernoulli-bit))
(defun draw-bernoulli (p &key (rng *random-state*))
  "Return T with probability p, otherwise NIL. Rationals are handled exactly."
  (etypecase p
    (integer (ecase p
               (0 NIL)
               (1 T)))
    (rational (let+ (((&accessors-r/o numerator denominator) p))
                (assert (<= numerator denominator))
                (< (next denominator rng) numerator)))
    (float (< (next (float 1 p) rng) p))))

(defun draw-bernoulli-bit (p &key (rng *random-state*))
  (if (draw-bernoulli p :rng rng) 1 0))


;; Use PR instead of P, otherwise both type predicate and structure member are called
;; r-bernoulli-p.
(define-rv r-bernoulli (pr)
  (:documentation "Bernoulli(pr) distribution, with probability PR for success and 1-PR
for failure."
   :include r-univariate)
  ((pr :type internal-float :reader T))
  (with-floats (pr)
    (check-probability pr :both)
    (make :pr pr))
  (mean () pr)
  (variance () (* pr (- 1 pr)))
  (draw (&key (rng *random-state*))
        (draw-bernoulli-bit pr :rng rng))
  (cdf (x)
       (cond ((< x 0) 0)
	     ((< x 1) (- 1 pr))
	     (T 1))))
