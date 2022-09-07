;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2021 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; Gamma distribution.
;;;
;;; Also provides a generator-standard-gamma, which returns a
;;; generator for a given alpha.

(declaim (inline standard-gamma1-d-c draw-standard-gamma1
                 generator-standard-gamma))

(defun standard-gamma1-d-c (alpha)
  "Return precalculated constants (values d c), useful for drawing
from a gamma distribution."
  (let* ((d (- (as-float alpha) (/ 3)))
         (c (/ (sqrt (* 9 d)))))
    (values d c)))

(defun draw-standard-gamma1 (alpha d c &key (rng *random-state*))
  "Return a standard gamma variate (beta=1) with shape parameter alpha
>= 1.  See Marsaglia and Tsang (2004).  You should precalculate d
and c using the utility function above. "
  ;; !! see how much the change in draw-standard-normal would speed this up
  (declare (optimize (speed 3))
           (type internal-float d c)
           #+sbcl (sb-ext:muffle-conditions sb-ext:compiler-note))
  (check-type alpha (internal-float 1))
  (tagbody
   top
     (let+ (((&values x v) (prog ()     ; loop was not optimized for some reason
                            top
                              (let* ((x (draw-standard-normal :rng rng))
                                     (v (expt (1+ (* c x)) 3)))
                                (if (plusp v)
                                    (return (values x v))
                                    (go top)))))
            (u (next 1d0 rng))
            (xsq (expt x 2)))
       (if (or (< (+ u (* 0.0331 (expt xsq 2))) 1d0)
               (< (log u) (+ (* 0.5 xsq) (* d (+ (- 1d0 v) (log v))))))
           (return-from draw-standard-gamma1 (* d v))
           (go top)))))


;;;
;;; CDF
;;;
(defun cdf-gamma%+ (x k θ)		;alternative implementation, with shape and scale
  "Return the cumulative gamma distribution function, shape k>0, scale θ>0"
  (cond ((or (< k 0)
	     (< θ 0))
	 double-float-nan)
	 ((< x 0) 0)
	 (t (incomplete-gamma k (/ x θ)))))

;;; This version mostly emulates R's dgamma
(defun cdf-gamma (x shape &key (rate 1 rate-supplied-p) (scale (/ rate) scale-supplied-p) (upper-tail nil) (log nil))
  "CDF of Gamma with parameterisation like that of R pgamma"
  (declare (ignore upper-tail log))
  (cond ((and rate-supplied-p
	      scale-supplied-p)
	 (error "Error, specify rate or scale but not both"))
	((not (and (plusp x)
		   (plusp shape)
		   (if rate-supplied-p  (plusp rate)  t)
		   (if scale-supplied-p (plusp scale) t)))
	 (error "All parameters to CDF-GAMMA must be greater than 0")))
  (nth-value 0
    (specfun:incomplete-gamma shape (/ x scale))))


;;;
;;; PDF
;;;

;;; Each of these implementations of PDF produce good results.
;;; Spot testing suggests that pdf-gamma agrees most closely with R's
;;; dgamma.

;;; Definition as in Boost
(defun pdf-gamma+ (x k θ)
  "Return the probability density function where:

K is the shape of the distribution
θ (theta) is the scale
X is the random variate"
  (/ (specfun::gamma-p-derivative k (/ x θ))
     θ))

(defun pdf-gamma* (x shape scale)
  (declare (double-float x shape scale))
  (/ (* (expt x (1- shape))
	(exp (/ (- x) scale)))
     (* (gamma shape)
	(expt scale shape))))

;; Reference: ? I don't recall where this came from
(defun pdf-gamma (x a b)			;a = shape, b = scale
  "Return the probability density function of a gamma distribution with shape a>0, scale b>0
Returns: x^(a-1)*exp(-x/b)/gamma(a)/b^a, x>0"
  (declare (double-float a b x))
  (cond ((or (<= a 0)
	     (<= b 0)
	     (< x 0))
	 (return-from pdf-gamma double-float-nan))
	((= x 0)
	 (cond ((= a 1)
		(/ b))
	       ((> a 1)
		0)
	       (t double-float-positive-infinity)))
	(t (/ (spfn:regularised-gamma-prefix a (/ x b)) x))))

(defun pdf-gamma% (x shape scale)
  (pdf-gamma x shape scale))



(define-rv r-gamma (alpha beta)
  (:documentation "Gamma(alpha,beta) distribution, with density proportional to x^(alpha-1) exp(-x*beta).  Alpha and beta are known as shape and inverse scale (or rate) parameters, respectively."
   :include r-univariate)
  ((alpha :type internal-float :reader t)
   (beta  :type internal-float :reader t))
  (with-floats (alpha beta)
    (assert (plusp alpha))
    (assert (plusp beta))
    (make :alpha alpha :beta beta))
  (mean () (/ alpha beta))
  (variance () (* alpha (expt beta -2)))
  (log-pdf (x &optional ignore-constant?)
           (maybe-ignore-constant
            ignore-constant?
            (with-floats (x)
              (- (+ (* alpha (log beta)) (* (1- alpha) (log x))) (* beta x)))
            (- (specfun:log-gamma alpha))))

  ;; note that R uses scale=1/beta (tpapp comment)
  (cdf (x)
       (with-floats (x)
	 ;; (cdf-gamma%+ x alpha (/ beta))) ;here for testing alternative implementation
	 (cdf-gamma x alpha :rate beta)))
      ;; (rmath:pgamma x alpha (/ beta) 1 0))))
  (quantile (q)
            (with-floats (q)
              (check-probability q :right)
                  (* (/ beta)
		     (cephes:igami alpha q))))
                  ;; (rmath:qgamma q alpha (/ beta) 1 0))))
  (draw (&key (rng *random-state*))
        ;; !! could optimize this by saving slots
        (if (< alpha 1d0)
            (let+ ((1+alpha (1+ alpha))
                   (1/alpha (/ alpha))
                   ((&values d c) (standard-gamma1-d-c 1+alpha)))
              ;; use well known-transformation, see p 371 of Marsaglia & Tsang (2000)
              (/ (* (expt (next 1d0 rng) 1/alpha)
                    (draw-standard-gamma1 1+alpha d c :rng rng))
                 beta))
            (let+ (((&values d c) (standard-gamma1-d-c alpha)))
              (/ (draw-standard-gamma1 alpha d c :rng rng) beta)))))


;;; Inverse gamma distribution.

(define-rv r-inverse-gamma (alpha beta)
  (:documentation "Inverse-Gamma(alpha,beta) distribution, with density p(x) proportional to x^(-alpha+1) exp(-beta/x)"
   :include r-univariate
   :num=-slots (alpha beta))
  ((alpha :type internal-float :reader t)
   (beta :type internal-float :reader t))
  (with-floats (alpha beta)
    (assert (plusp alpha))
    (assert (plusp beta))
    (make :alpha alpha :beta beta))
  (mean () (if (< 1 alpha)
               (/ beta (1- alpha))
               (error "Mean is defined only for ALPHA > 1")))
  (variance () (if (< 2 alpha)
                   (/ (expt beta 2) (expt (1- alpha) 2) (- alpha 2))
                   (error "Variance is defined only for ALPHA > 2")))
  (log-pdf (x &optional ignore-constant?)
           (maybe-ignore-constant
            ignore-constant?
            (- (* (- (1+ alpha)) (log x)) (/ beta x))
            (- (* alpha (log beta)) (specfun:log-gamma alpha))))
  (draw (&key (rng *random-state*))
        (if (< alpha 1d0)
            (let+ ((1+alpha (1+ alpha))
                   (1/alpha (/ alpha))
                   ((&values d c) (standard-gamma1-d-c 1+alpha)))
              ;; use well known-transformation, see p 371 of Marsaglia & Tsang (2000)
              (/ beta
                 (* (expt (next 1d0 rng) 1/alpha)
                    (draw-standard-gamma1 1+alpha d c :rng rng))))
            (let+ (((&values d c) (standard-gamma1-d-c alpha)))
              (/ beta (draw-standard-gamma1 alpha d c :rng rng))))))
