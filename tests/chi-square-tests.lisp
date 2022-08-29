;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite chi-square-distribution
    :description "Test functions for the chi-square distribution."
    :in all-tests)
(in-suite chi-square-distribution)

(test chi-square-moments
  (let* ((nu 9d0)
         (rv (r-chi-square nu)))
    (is (num= nu (mean rv))
	(is (num= (* 2 nu) (variance rv))))))

(test chi-square-cdf
  (is (num= 0.2211992 (cdf (r-chi-square 2) 0.5))))

(test inverse-chi-square-moments
  (let* ((nu 9)
	 (s^2 pi)
	 (rv (r-inverse-chi-square nu s^2)))
    (is (num= (* (/ nu (- nu 2)) s^2) (mean rv)))
    (is (num= (/ (* 2 (expt nu 2) (expt s^2 2))
		 (* (expt (- nu 2) 2) (- nu 4)))
	      (variance rv)))))
