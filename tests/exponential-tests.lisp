;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite exponential-distribution
  :description "Test functions for the exponential distribution."
  :in all-tests)
(in-suite exponential-distribution)

(test exponential-draws
  (is (same-univariate-moments (r-exponential 1)))
  (is (same-univariate-moments (r-exponential 19) :var-band 0.3d0)))
