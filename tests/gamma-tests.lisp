;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite gamma-distribution
  :description "Test functions for the gamma distribution."
  :in all-tests)
(in-suite gamma-distribution)

(test gamma-draws
  (signals error (r-gamma 9 0))
  (signals error (r-gamma -7 1))
  (is (same-univariate-moments (r-gamma 1 1)))
  (is (same-univariate-moments (r-gamma 12 1)))
  (is (same-univariate-moments (r-gamma 8 1)))
  (is (same-univariate-moments (r-gamma 0.5 pi))))

(test gamma-cdf
  (is (num= 0.6321206d0 (cdf (r-gamma 1 1) 1d0)))
  (is (num= 0.9926168   (cdf (r-gamma 1.5 2) 3)))

  (assert-q-cdf-consistency (r-gamma 2 3) .2)
  (assert-q-cdf-consistency (r-gamma 1 9) .7))

(test inverse-gamma-draws
  (is (same-univariate-moments (r-inverse-gamma 12 1)))
  (is (same-univariate-moments (r-inverse-gamma 4 8)))
  (signals error (mean (r-inverse-gamma 0.5 1)))
  (signals error (variance (r-inverse-gamma 1.5 1))))
