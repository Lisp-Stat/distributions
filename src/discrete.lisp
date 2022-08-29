;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

;; TODO: Add shuffle! and elt (see :alexandria).

(defun distinct-random-integers (count limit &key (rng *random-state*))
  "Return a vector of COUNT distinct random integers, in increasing order,
drawn from the uniform discrete distribution on {0 , ..., limit-1}."
  (assert (<= count limit))
  (distinct-random-integers-dense count limit :rng rng))

(defun distinct-random-integers-dense (count limit &key (rng *random-state*))
  "Implementation of DISTINCT-RANDOM-INTEGERS when count/limit is (relatively)
high. Implements algorithm S from @cite{taocp3}, p 142."
  (let ((result (make-array count)))
    (loop with selected = 0
          for index below limit
          do (when (draw-bernoulli (/ (- count selected)
                                      (- limit index))
				   :rng rng)
               (setf (aref result selected) index)
               (incf selected)
               (when (= selected count)
                 (return))))
    result))


;;; Discrete distribution.
;;;
;;; ?? The implementation may be improved speedwise with declarations and
;;; micro-optimizations.  Not a high priority.  However, converting arguments
;;; to internal-float provided a great speedup, especially in cases when the
;;; normalization resulted in rationals -- comparisons for the latter are
;;; quite slow.

(define-rv r-discrete (probabilities)
  (:documentation "Discrete probabilities."
   :include r-univariate
   :instance instance)
  ((probabilities :type float-vector :reader t)
   (prob :type float-vector)
   (alias :type (simple-array fixnum (*)))
   (n-float :type internal-float))
  ;; algorithm from Vose (1991)
  (let* ((probabilities (as-float-probabilities probabilities))
         (p (copy-seq probabilities))   ; this is modified
         (n (length probabilities))
         (alias (make-array n :element-type 'fixnum))
         (prob (make-array n :element-type 'internal-float))
         (n-float (as-float n))
         (threshold (/ n-float))
         small
         large)
    ;; separate using threshold
    (dotimes (i n)
      (if (> (aref p i) threshold)
          (push i large)
          (push i small)))
    ;; reshuffle
    (loop :while (and small large) :do
             (let* ((j (pop small))
                    (k (pop large)))
               (setf (aref prob j) (* n-float (aref p j))
                     (aref alias j) k)
               (if (< threshold (incf (aref p k)
                                      (- (aref p j) threshold)))
                   (push k large)
                   (push k small))))
    ;; the rest use 1
    (loop :for s :in small :do (setf (aref prob s) 1d0))
    (loop :for l :in large :do (setf (aref prob l) 1d0))
    ;; save what's needed
    (make :probabilities probabilities :prob prob :alias alias :n-float n-float))
  (mean ()
        (loop
          for p across probabilities
          for i from 0
          summing (* p i)))
  (variance ()
            (loop
              with mean = (mean instance)
              for p across probabilities
              for i from 0
              summing (* p (expt (- i mean) 2))))
  (log-pdf (i &optional ignore-constant?)
           (declare (ignore ignore-constant?))
           (log (aref probabilities i)))
  (cdf (i)
       ;; NIL gives the whole CDF
       (if i
           (loop ; note: loop semantics takes care of indices outside support
             for p across probabilities
             repeat (1+ i)
             summing p)
           (nu:cumulative-sum probabilities
                              :result-type 'internal-float-vector)))
  (draw (&key (rng *random-state*))
        (multiple-value-bind (j p) (floor (next n-float rng))
          (if (<= p (aref prob j))
              j
              (aref alias j)))))
