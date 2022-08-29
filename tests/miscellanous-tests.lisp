;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

;;;; Formerly discrete.lisp, these appear to be discrete tests for
;;;; various disdributions.

(defun count-draws-if (count generator &optional (predicate #'identity))
  "Call GENERATOR COUNT times, return the number of draws that satisfy PREDICATE."
  (loop repeat count
        summing (if (funcall predicate (funcall generator)) 1 0)))

(defun same-proportion? (probability count generator
                         &key (predicate #'identity)
                              (tail 0.01))
  "Test if out of COUNT draws of GENERATOR, the proportion of those satisfying
PREDICATE is `close' to PROBABILITY.  Uses a normal approximation to the
binomial distribution, with the rejection probability 2*TAIL, symmetrically."
  (check-type probability (real 0 1))
  (assert (< 100 count))
  (let ((rv (r-normal (* count probability)
                      (max (* count probability (- 1 probability)) 1e-4)))
        (result (count-draws-if count generator predicate)))
    (values (< (quantile rv tail) result (quantile rv (- 1 tail)))
            (float (/ result count) 1d0))))

(def-suite miscellanous-tests
  :description "Miscellanous discrete tests of various distribution."
  :in all-tests)
(in-suite miscellanous-tests)

(test bernoulli-proportions
  (is (not (draw-bernoulli 0)))
  (is (draw-bernoulli 1))
  (is (same-proportion? 0.3 10000
				 (lambda () (draw-bernoulli 3/10))))
  (is (same-proportion? 1/31 100000
				 (lambda () (draw-bernoulli 1/31))))
  (is (same-proportion? 0.99d0 10000
				 (lambda () (draw-bernoulli 0.99d0))))
  (is (same-proportion? 0.1 10000
				 (lambda () (draw-bernoulli 0.10)))))

;; TODO: Test binomial, geometric, and poisson. What's the best test?

(test distinct-random-integers
  (flet ((count-test (number count limit &key (n-draws 10000))
           "Test (DISTINCT-RANDOM-INTEGERS COUNT LIMIT) by counting the times NUMBER shows up in draws."
           (is (< -1 number limit))
           (same-proportion? (/ count limit)
                             n-draws
                             (lambda () (distinct-random-integers count limit))
                             :predicate (lambda (result) (find number result)))))
    (is (count-test 42 5 100))
    (is (count-test 93 6 100))
    (is (count-test 999 6 1000))
    (is (count-test 9 10 10))))

