;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

(def-suite all-tests
    :description "The master suite of all DISTRIBUTIONS tests.")

(in-suite all-tests)

#+genera (setf *print-array* t)

(defun test-distributions ()
  (run! 'all-tests))

(defun assert-q-cdf-consistency (rv q)
  "Calculate X from Q, then Q from X, and compare."
  (is (num= (cdf rv (distributions:quantile rv q)) q)))

(defun z-score (n mean variance sample-mean)
  "Calculate abs(z) based on theoretical mean and variance and sample mean."
  (abs (* (- sample-mean mean)
          (sqrt (/ n variance)))))

(defun same-univariate-moments (rv &key (n 100000) (z-band 4d0) (var-band 0.1))
  "Sample a univariate random variable N times and compare with expected moments, using

  1. the z-score of the mean (should be below Z-BAND in absolute value),

  2. the variance with NUM= using VAR-BAND as a tolerance."
  (let+ (((&accessors-r/o mean variance) rv)
         (sample-moments (nu.stats:central-sample-moments nil)))
    (loop repeat n
          do (nu.stats:add sample-moments (draw rv)))
    (and (< (z-score n mean variance (nu.stats:mean sample-moments)) z-band)
         (num= variance (nu.stats:variance sample-moments) var-band))))

;; This was commented out in Papps version.
;; (defun same-sample-mean-variance (rv &key )
;;   "Generate a sample of length N from RV, then compare moments
;; COMPARE-SAMPLE-MEAN-VARIANCE.  For univariate and multivariate distributions."
;;     (if (vectorp mean)
;;         (let ((moments (nu:central-sample-moments
;;                         (aops:generate (funcall ))) )))
;;         )

;;     (multivariate? (vectorp mean))
;;     (sample (sweep (if multivariate?
;;                        (conforming-accumulator 'mean mean)
;;                        'variance)
;;                    (replicating rv n)))
;;     (if multivariate?
;;         (every (curry #'> z-band)
;;                (map 'vector (curry #'z-score n) mean (diagonal variance)
;;                     (mean sample)))
;;         )))

(defgeneric relative-difference (a b)
  (:documentation "Relative difference of A and B.")
  (:method ((a number) (b number))
    (/ (abs (- a b))
       (max 1 (abs a) (abs b))))
  (:method ((a array) (b array))
    "Relative difference of A and B."
    (assert (equalp (array-dimensions a) (array-dimensions b)))
    (reduce #'max
            (map 'vector #'relative-difference
                 (aops:flatten a) (aops:flatten b))))
  (:method ((a array) b)
    (relative-difference a (aops:as-array b))))

#| TODO: Remove LLA dependency
(defun random-y-x (n k
                   &optional
                   (x-rv (r-normal 0 9))
                   (e-rv (r-normal 0 2))
                   (beta (aops:generate* 'lla-double (generator (r-normal 0 1)) k)))
  "Generate random Y and X for testing regressions."
  (let* ((x (aops:generate* 'lla-double (generator x-rv) (list n k)))
         (y (e+ (mm x beta) (aops:generate* 'lla-double n (generator e-rv)))))
    (values y x)))
|#
