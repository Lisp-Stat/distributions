;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package #:cl-random)

;;; dummy observations for regressions

(defun add-regression-dummies (y x prior dummy-generator)
  "Add prior to Y and X in the form of dummy observations, return (values Y
X).  Priors are exptected in the format (y . x), otherwise DUMMY-GENERATOR is
called with the prior to generate dummy observations."
  (flet ((add (dummies)
           (values (concat y (car dummies))
                   (stack t :vertically
                          x (cdr dummies)))))
    (typecase prior
      (null (values y x))
      (cons (add prior))
      (t (add (funcall dummy-generator prior))))))

;;; linear regression

(defclass linear-regression ()
  ((posterior :accessor posterior :initarg :posterior)
   (r^2 :accessor r^2 :initarg :r^2)
   (s^2 :accessor s^2 :initarg :s^2)))

(defun linear-regression-dummies (prior)
  "Return dummy observations as (Y . X) for the given prior, for use in a
linear regression."
  (check-type prior linear-regression)
  (bind (((:accessors-r/o posterior s^2) prior)
         ((:accessors-r/o nu multivariate-normal) posterior)
         (nu (as-integer nu))
         (s (sqrt s^2))
         ((:slots-r/o mean variance-left-sqrt) multivariate-normal)
         (k (length mean))
         (r-t (e/ variance-left-sqrt s))
         (y (concat (solve r-t mean) (make-array* nu 'double-float s)))
         (x (stack 'double-float :vertical
                   (invert r-t)
                   (make-array* (list nu k) 'double-float 0d0))))
    (cons y x)))

(defun linear-regression (y x &key prior)
  "Linear regression of Y on X with (improper) reference prior (ie standard
Bayesian OLS).  Prior is used (dummy observations or whatever is accepted by
LINEAR-REGRESSION-DUMMIES."
  (bind ((x (typecase x
              (matrix x)
              (vector (as-column x))
              (t (as-array x))))
         ((:values y x) (add-regression-dummies y x prior
                                                #'linear-regression-dummies)))
    (bind (((:values b ss nu qr) (least-squares y x :method :qr))
           (s^2 (/ ss nu))
           (sigma (e* (invert-xx qr) s^2)))
      (make-instance 'linear-regression
                     :posterior (r-multivariate-t b sigma nu)
                     :r^2 (- 1d0 (/ ss (sse y)))
                     :s^2 s^2))))

;;; various accessors

(defmethod nu ((lr linear-regression))
  (nu (posterior lr)))

(defmethod mean ((lr linear-regression))
  (bind (((:slots-r/o posterior s^2) lr))
    (values (mean (posterior lr))
            (* s^2 (mean (scaling-factor posterior))))))

(defmethod variance ((lr linear-regression))
  (bind (((:slots-r/o posterior s^2) lr))
    (values (variance (posterior lr))
            (* (expt s^2 2) (variance (scaling-factor posterior))))))

(defmethod draw ((lr linear-regression) &key)
  (bind (((:values beta scaling-factor) (draw (posterior lr))))
    (values beta (* scaling-factor (s^2 lr)))))

