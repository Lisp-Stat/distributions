;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2021 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions-tests)

#+genera (setf *print-array* t)

(def-suite discrete-distribution
  :description "Test functions for the discrete distribution."
  :in all-tests)
(in-suite discrete-distribution)

(defun empirical-frequencies (discrete-rv &key (n 100000))
  "Count realizations for each value."
  (check-type n fixnum)
  (let ((count (make-array (length (probabilities discrete-rv))
                           :element-type 'fixnum :initial-element 0)))
    (loop repeat n
          do (incf (aref count (draw discrete-rv))))
    count))

(defun average-relative-deviation (frequencies probabilities &key (n (reduce #'+ frequencies)))
  "Sum of the absolute values of relative deviations from expected probabilities."
  (assert (= (length frequencies) (length probabilities)))
  (nu.stats:mean (map 'vector
                        (lambda (f p)
                          (let ((e (* n p)))
                            (/ (abs (- f e)) e)))
                        frequencies probabilities)))

(defun discrete-deviation (discrete-rv &key (n 100000))
  "Probably a chi-square test would be better, but this isn't very important."
  (average-relative-deviation (empirical-frequencies discrete-rv :n n)
                              (probabilities discrete-rv)
                              :n n))

(test discrete-moments
  (let ((rv0 (r-discrete #(1/4 1/4 1/2)))
        (rv1 (r-discrete #(1/3 1/6 1/3)))) ; will be rescaled
    ;; first distribution
    (is (num= #(0.25d0 0.25 0.5) (probabilities rv0)))
    (is (num= 1.25 (mean rv0)))
    (is (num= 0.6875 (variance rv0)))
    (is (num= 0.5 (cdf rv0 1)))
    ;; second distribution -- this is rescaled to sum to 1
    (is (num= #(0.4d0 0.2d0 0.4d0) (probabilities rv1)))
    (is (num= 1 (mean rv1)))
    (is (num= 0.8d0 (variance rv1)))
    (is (num= 0.4d0 (cdf rv1 0)))))


