;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; Chi-square and inverse-chi-square distribution (both scaled).
;;; We just reparametrize and rely on GAMMA and INVERSE-GAMMA.

(defun r-chi-square (nu)
  "Chi-square distribution with NU degrees of freedom."
  (r-gamma (/ nu 2) 0.5d0))

(defmethod nu ((r-gamma r-gamma))
  (* 2 (r-gamma-alpha r-gamma)))

(defun r-inverse-chi-square (nu &optional (s^2 1d0))
  "Generalized inverse chi-square distribution.  Reparametrized to INVERSE-GAMMA."
  (let ((nu/2 (/ nu 2)))
    (r-inverse-gamma nu/2 (* nu/2 s^2))))

(defmethod nu ((r-inverse-gamma r-inverse-gamma))
  (* 2 (r-inverse-gamma-alpha r-inverse-gamma)))

(defmethod s^2 ((r-inverse-gamma r-inverse-gamma))
  (let+ (((&structure r-inverse-gamma- alpha beta) r-inverse-gamma))
    (/ beta alpha)))
