;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.
(in-package :distributions)

;;; Poisson distribution

(declaim (inline draw-poisson))
(defun draw-poisson (lamda &key (rng *random-state*))
  "Return the number of events that occur with probability LAMDA.  The algorithm is from Donald E. Knuth (1969).  Seminumerical Algorithms.  The Art of Computer Programming, Volume 2. Addison Wesley.  WARNING: It's simple but only linear in the return value K and is numerically unstable for large LAMDA."
  (do ((l (exp (- lamda)))
       (k 0 (1+ k))
       (p 1d0 (* p u))
       (u (next 1d0 rng) (next 1d0 rng)))
      ((<= p l) k)))
