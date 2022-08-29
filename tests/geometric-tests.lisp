;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite geometric-distribution
  :description "Test functions for the geometric distribution."
  :in all-tests)
(in-suite geometric-distribution)

(test geometric-draws
  ;; TODO: What's wrong with p=1?
  ;; (is (same-univariate-moments (r-geometric 1))) 
  (is (same-univariate-moments (r-geometric 0.3)))
  (is (same-univariate-moments (r-geometric 1/6)))
  (is (same-univariate-moments (r-geometric 0.98))))
