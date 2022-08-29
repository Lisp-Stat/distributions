;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite binomial-distribution
  :description "Test functions for the binomial distribution."
  :in all-tests)
(in-suite binomial-distribution)

(test binomial-draws
  (is (same-univariate-moments (r-binomial 0.2 100)))
  (is (same-univariate-moments (r-binomial 0.1 1000)))
  (is (same-univariate-moments (r-binomial 0.9 200)))
  (is (same-univariate-moments (r-binomial 0.5 50))))

