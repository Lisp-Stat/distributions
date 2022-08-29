;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite t-distribution
  :description "Test functions for the T distribution."
  :in all-tests)
(in-suite t-distribution)

(test t-draws
  (is (same-univariate-moments (r-t 0 1 4.1)))
  (is (same-univariate-moments (r-t 10 1 5)))
  (is (same-univariate-moments (r-t 0 112 9)))
  (signals error (r-t 0 1 0))
  (signals error (r-t 0 1 -1))
  (signals error (r-t 0 -1 3)))
