;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS-TESTS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions-tests)

#+genera (setf *print-array* t)

(def-suite continuous-time-tests
  :description "Test functions for continuous time functions."
  :in all-tests)
(in-suite continuous-time-tests)

(test uniformized-markov-jump
  (let* ((n 100000)
         (keys #(:a :b :c))
         (rates #(1 2 3))
         (rv (r-uniformized-markov-jump rates :transition-rate 10 :keys keys
                                              :no-change :no-change))
         (possible-keys (concatenate 'vector (vector :no-change) keys))
         (durations (make-array n :element-type 'double-float))
         (jumps (make-array n)))
    (dotimes (i n)
      (setf (values (aref durations i) (aref jumps i)) (draw rv)))
    (let ((*num=-tolerance* 0.01d0))
      (is (num= 0.1 (clnu:mean durations)))
    (let ((*num=-tolerance* 0.1d0))
      (is (num= (* 0.1 n) (count :a jumps)))
      (is (num= (* 0.2 n) (count :b jumps)))
      (is (num= (* 0.3 n) (count :c jumps)))
      (is (num= (* 0.4 n) (count :no-change jumps))))
    (is (every #'alexandria:non-negative-real-p durations))
    (is (every (lambda (j) (find j possible-keys)) jumps)))))

(test uniformized-markov-jump2
  (let+ ((n 100000)
         (keys #(:a :b :c))
         (rates #(0.1 0.9 1.5))
         (total-rates (clnu:sum rates))
         (durations (make-array n :element-type 'double-float))
         (jumps (make-array n))
         ((&flet test-count (key rate)
            (let ((count (count key jumps))
                  (expected (* (/ rate total-rates) n)))
               (format *debug-io*
                       "key: ~A  expected count: ~A  actual count: ~A~%"
                       key (round expected) count)
              (is (num= expected count)  "Expected ~A but got ~A for key ~A" (round expected) count key))))
         (rv (r-uniformized-markov-jump rates :keys keys)))
    (dotimes (i n)
      (setf (values (aref durations i) (aref jumps i)) (draw rv)))
    (let ((*num=-tolerance* 0.02d0))
      (is (num= (/ total-rates) (clnu:mean durations)))
    (let ((*num=-tolerance* 0.02d0))
      (map nil #'test-count keys rates))
    (is (every #'alexandria:non-negative-real-p durations))
    (is (every (lambda (j) (find j keys)) jumps)))))
