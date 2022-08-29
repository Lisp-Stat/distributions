;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

;;; Binomial distribution

(declaim (inline draw-binomial))
(defun draw-binomial (p n &key (rng *random-state*))
  "Return the number of successes out of N Bernoulli trials with probability
of success P."
  (let ((successes 0))
    (dotimes (i n successes)
      (when (draw-bernoulli p :rng rng)
	(incf successes)))))

(define-rv r-binomial (pr n)
  (:documentation "Binomial(pr,n) distribution, with N Bernoulli trials with probability PR for success."
   :include r-univariate)
  ((pr :type internal-float :reader T)
   (n :type integer :reader T))
  (with-floats (pr)
    (check-probability pr)
    (assert (plusp n))
    (make :pr pr :n n))
  (mean () (* n pr))
  (variance () (* n pr (- 1 pr)))
  (draw (&key (rng *random-state*))
        (draw-binomial pr n :rng rng)))
