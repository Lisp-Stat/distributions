;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite normal-distribution
  :description "Test functions for the normal and log-normal distributions."
  :in all-tests)
(in-suite normal-distribution)

;; Note: currently comparing to values from R. It would be more useful
;; to use "exact" (ie calculated with arbitrary precision) values from
;; elsewhere, e.g. Maxima or Boost.

(test normal-cdf
  (let ((rv (r-normal 0 1)))
    (is (num= 0.158655253931457 (cdf rv -1d0)))
    (is (num= 0.999999713348428 (cdf rv 5d0)))
    (is (num= 0.758036347776927 (cdf rv 0.7d0)))))

(test normal-pdf
  (let ((rv (r-normal 5 (expt 19 2))))
    (is (num= 0.02073685169643458d0 (pdf rv 2d0)))
    (is (num= 0.01775714089407024d0 (pdf rv 16d0)))
    (is (num= 0.0000000459719932600508d0 (pdf rv 102d0)))))

(test normal-draws
  (is (same-univariate-moments (r-normal 0 1)))
  (is (same-univariate-moments (r-normal 10 1)))
  (is (same-univariate-moments (r-normal 0 144))))

(test truncated-normal-functions
  (let ((rv (r-truncated-normal -0.5 nil)))
    (is (num= 0 (pdf rv -0.7)))
    (is (num= 0.5515669 (pdf rv -0.3)))
    (is (num= 0 (cdf rv -0.7)))
    (is (num= -0.5 (quantile rv 0)))
    (is (num= 0.1063703 (cdf rv -0.3)))
    (is (num= -0.3 (quantile rv 0.1063703))))
  (let ((rv (r-truncated-normal -0.5 nil -0.4 2.5)))
    (is (num= 0 (pdf rv -0.7)))
    (is (num= 0.3090382 (pdf rv -0.3)))
    (is (num= 0 (cdf rv -0.7)))
    (is (num= 0.06184061 (cdf rv -0.3)))
    (is (num= -0.5 (quantile rv 0)))
    (is (num= -0.3 (quantile rv 0.06184061)))))

(test truncated-normal-draws
  ;; LEFT
  ;; not including zero
  (is (same-univariate-moments (r-truncated-normal 0.5d0 nil 1d0 0.72d0)))
  ;; (is (same-univariate-moments
  ;;          (r-truncated-normal 100 nil 0 1)))
  ;; including zero
  (is (same-univariate-moments (r-truncated-normal -0.7d0 nil 0d0 7d0)))
  ;; ;; RIGHT
  ;; ;; not including zero
  ;; (is (same-univariate-moments (make-instance 'truncated-normal :right -0.5d0
  ;;                                            :mu 1.5d0 :sigma 2d0)))
  ;; ;; including zero
  ;; (is (same-univariate-moments (make-instance 'truncated-normal :right 0.7d0
  ;;                                            :mu -4.2d0 :sigma 2d0)))
  ;; ;; BOTH LEFT AND RIGHT
  ;; ;; wide
  ;; (is (same-univariate-moments (make-instance 'truncated-normal
  ;;                                            :left -0.7d0 :right 4d0)))
  ;; ;; narrow
  ;; (is (same-univariate-moments (make-instance 'truncated-normal
  ;;                                            :left -0.25d0 :right 0.1d0)))
  ;; ;; support above 0
  ;; (is (same-univariate-moments (make-instance 'truncated-normal
  ;;                                            :left 1d0 :right 5d0)))
  ;; ;; support below 0
  ;; (is (same-univariate-moments (make-instance 'truncated-normal
  ;;                                            :left -9d0 :right -5d0)))
  ;; NOT TRUNCATED
  (is (same-univariate-moments (r-truncated-normal nil nil 5d0 9d0))))

(test log-normal-pdf
  (let ((rv (r-log-normal 5 19)))
    (is (num= 0.0102321986262048220 (pdf rv 2d0)))
    (is (num= 0.0013033232558763653d0 (pdf rv 16d0)))
    (is (num= 0.0002058124737511057d0 (pdf rv 102d0)))))

(test log-normal-draws
  (is (same-univariate-moments (r-log-normal 0 1)))
  (is (same-univariate-moments (r-log-normal 10 1)))
  (is (same-univariate-moments (r-log-normal 0 0.5))))


