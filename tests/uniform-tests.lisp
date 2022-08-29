;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite uniform-distribution
  :description "Test functions for the uniform distribution."
  :in all-tests)
(in-suite uniform-distribution)

(test uniform-draws
  (is (same-univariate-moments (r-uniform 0 1)))
  (is (same-univariate-moments (r-uniform -9 1)))
  (is (same-univariate-moments (r-uniform 0 107)))
  (is (same-univariate-moments (r-uniform 19 57))))
