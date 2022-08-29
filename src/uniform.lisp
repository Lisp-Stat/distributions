;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

(defun draw-uniform (left right &key (rng *random-state*))
  "Return a random variable from the uniform distribution between LEFT and RIGHT. It's type is
the same as that of (- LEFT RIGHT)."
  (+ left (next (- right left) rng)))

(define-rv r-uniform (left right)
  (:documentation "Uniform(left,right) distribution."
   :include r-univariate)
  ((left :type internal-float :reader t)
   (right :type internal-float :reader t)
   (width :type internal-float))
  (with-floats (left right)
    (assert (< left right))
    (let ((width (- right left)))
      (make :left left :right right :width width)))
  (mean () (/ (+ left right) 2))
  (variance () (/ (expt width 2) 12d0))
  (log-pdf (x &optional ignore-constant?)
           (declare (ignorable ignore-constant?))
           (with-floats (x)
             (if (<= left x right)
                 (- (log width))
                 nil)))
  (cdf (x)
       (with-floats (x)
         (cond
           ((< x left) 0d0)
           ((< right x) 1d0)
           (t (/ (- x left) width)))))
  (quantile (p)
            (with-floats (p)
              (check-probability p)
              (+ left (* p (- right left)))))
  (draw (&key (rng *random-state*))
        (+ left (next width rng))))
