;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite rayleigh-distribution
  :description "Test functions for the rayleigh distribution."
  :in all-tests)
(in-suite rayleigh-distribution)

(test rayleigh-draws
  (is (same-univariate-moments (r-rayleigh 1)))
  (is (same-univariate-moments (r-rayleigh 0.0001d0)))
  (is (same-univariate-moments (r-rayleigh 1d0)))
  (is (same-univariate-moments (r-rayleigh 100)))
  (is (same-univariate-moments (r-rayleigh PI))))

(test rayleigh-cdf
  (is (num= 0.0d0
		   (cdf (r-rayleigh 250d0) 0d0)))
  (is (num= 7.99997d-6
		   (cdf (r-rayleigh 250d0) 1d0)))
  (is (num= 0.00079968d0
		   (cdf (r-rayleigh 250d0) 10d0)))
  (is (num= 0.0768837d0
		   (cdf (r-rayleigh 250d0) 100d0))))

