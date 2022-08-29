;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite bernoulli-distribution
  :description "Test functions for the Bernoulli distribution."
  :in all-tests)
(in-suite bernoulli-distribution)

(test bernoulli-draws
  (is (same-univariate-moments (r-bernoulli 0.001)))
  (is (same-univariate-moments (r-bernoulli 0.3)))
  (is (same-univariate-moments (r-bernoulli 1/3)))
  (is (same-univariate-moments (r-bernoulli 0.8))))
