;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite beta-distribution
  :description "Test functions for the beta distribution."
  :in all-tests)
(in-suite beta-distribution)

(test beta-draws
  (is (same-univariate-moments (r-beta 1 1)))
  (is (same-univariate-moments (r-beta 12 1)))
  (is (same-univariate-moments (r-beta 1 8)))
  (is (same-univariate-moments (r-beta 0.5 pi)))
  (is (num= 0.001343620695608248967121
	    (quantile (r-beta 0.3d0 0.6d0) 0.11))))

