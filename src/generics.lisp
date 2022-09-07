;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

(defstruct r-univariate
  "Univariate distribution.")

(defgeneric quantile (random-variable q) ; also defined in num-utils
  (:documentation "Quantile of RANDOM-VARIABLE at Q."))

(defgeneric standard-deviation (random-variable)
  (:documentation "Standard deviation of random variable.")
  (:method ((random-variable r-univariate))
    (sqrt (variance random-variable))))

(defgeneric nu (distribution)
  (:documentation "Return the degrees of freedom when applicable."))

(defgeneric s^2 (distribution)
  (:documentation "Return the scale when applicable."))
