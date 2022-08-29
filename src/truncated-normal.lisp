;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: DISTRIBUTIONS -*-
;;; Copyright (c) 2019-2020 Symbolics Pte. Ltd. All rights reserved.
(in-package #:distributions)

;;; All of the code commented out with ';' was done by Papp.

;;; It appears there was an attempt to write truncated-normal as a
;;; class and generic functions. I do not know if this was a prior
;;; attempt, or whether or not Papp was exploring a potential new way
;;; to architect the system.

;;; Truncated normal distribution (univariate).

(defun truncated-normal-moments% (N mu sigma left right
                                  &optional (m0 nil m0?))
  "N=0 gives the total mass of the truncated normal, used for normalization,
N=1 the mean, and N=2 the variance.  where p(x) is the normal density.  When LEFT or RIGHT are NIL, they are taken to be - or + infinity, respectively.  M0 may be provided for efficiency if would be calculated multiple times.  The formulas are from Jawitz (2004)."
  (if (zerop N)
      (- (if right (cdf-normal% right mu sigma) 1d0)
         (if left (cdf-normal% left mu sigma) 0d0))
      (let+ (((&flet part (x)
                (if x
                    (let ((y (exp (/ (expt (to-standard-normal x mu sigma) 2)
                                     -2))))
                      (values y (* (+ mu x) y)))
                    (values 0d0 0d0))))
             (m0 (if m0?
                     m0
                     (truncated-normal-moments% 0 mu sigma left right)))
             ((&flet diff (r l)
                (/ (* sigma (- r l))
                   m0 (sqrt (* 2 pi)))))
             ((&values l1 l2) (part left))
             ((&values r1 r2) (part right))
             (mean-mu (diff l1 r1)))
        (ecase N
          (1 (+ mean-mu mu))
          (2 (+ (diff l2 r2) (- (expt sigma 2)
                                (expt mean-mu 2) (* 2 mu mean-mu))))))))

(defun draw-left-truncated-standard-normal (left alpha &key (rng *random-state*))
  "Draw a left truncated standard normal, using an Exp(alpha,left) distribution.  LEFT is the standardized boundary, ALPHA should be calculated with TRUNCATED-NORMAL-OPTIMAL-ALPHA."
  (try ((z (+ (/ (draw-standard-exponential :rng rng) alpha) left))
        (rho (exp (* (expt (- z alpha) 2) -0.5))))
       (<= (next 1d0 rng) rho) z))

(defun truncated-normal-optimal-alpha (left)
  "Calculate optimal exponential parameter for left-truncated normals.  LEFT is the standardized boundary."
  (/ (+ left (sqrt (+ (expt left 2) 4d0)))
     2d0))

(define-rv left-truncated-normal (mu sigma left)
  (:documentation "Truncated normal distribution with given mu and sigma (corresponds to the mean and standard deviation in the untruncated case, respectively), on the interval [left, \infinity)."
   :include r-univariate)
  ((mu :type internal-float)
   (sigma :type internal-float)
   (left :type internal-float)
   (left-standardized :type internal-float)
   (m0 :type internal-float)
   (alpha :type internal-float))
  (with-floats (mu sigma left)
    (let ((left-standardized (to-standard-normal left mu sigma)))
      (make :mu mu :sigma sigma :left left :left-standardized left-standardized
            :m0 (truncated-normal-moments% 0 mu sigma left nil)
            :alpha (truncated-normal-optimal-alpha left-standardized))))
  (log-pdf (x &optional ignore-constant?)
           (when (<= left x)
             (maybe-ignore-constant ignore-constant?
                                    (with-floats (x)
                                      (/ (expt (- x mu) 2)
                                         (expt sigma 2) -2d0))
                                    (- +normal-log-pdf-constant+ (log sigma)
                                       (log m0)))))
  (cdf (x) (if (<= left x)
               (/ (1- (+ (cdf-normal% x mu sigma) m0)) m0)
               0d0))
  (quantile (q)
            (with-floats (q)
              (check-probability q :right)
	      (quantile-normal% (+ (* q m0) (- 1 m0)) mu sigma)))
  (mean () (truncated-normal-moments% 1 mu sigma left nil))
  (variance () (truncated-normal-moments% 2 mu sigma left nil))
  (draw (&key (rng *random-state*))
        (from-standard-normal
         (draw-left-truncated-standard-normal left-standardized alpha :rng rng)
         mu sigma)))

(defun r-truncated-normal (left right &optional (mu 0d0) (sigma 1d0))
  "Truncated normal distribution.  If LEFT or RIGHT is NIL, it corresponds to -/+ infinity."
  (cond
    ((and left right) (error "not implemented yet"))
    (left (left-truncated-normal mu sigma left))
    (right (error "not implemented yet") )
    (t (r-normal mu (expt sigma 2)))))


;; (defclass truncated-normal (univariate)
;;   ((mu :initarg :mu :initform 0d0 :reader mu :type internal-float)
;;    (sigma :initarg :sigma :initform 1d0 :reader sigma :type positive-internal-float)
;;    (left :initarg :left :initform nil :reader left :type truncation-boundary)
;;    (right :initarg :right :initform nil :reader right :type truncation-boundary)
;;    (mass :type (internal-float 0d0 1d0) :documentation "total mass of the raw PDF")
;;    (mean :reader mean :type internal-float :documentation "mean")
;;    (variance :reader variance :type positive-internal-float :documentation "variance")
;;    (cdf-left :type internal-float :documentation "CDF at left"))
;;   (:documentation ))

;; (define-printer-with-slots truncated-normal mu sigma left right)

;; (defmethod initialize-instance :after ((rv truncated-normal) &key
;;                                        &allow-other-keys)
;;   ;; !!! calculations of mass, mean, variance are very bad if the
;;   ;; support is far out in the tail.  that should be approximated
;;   ;; differently (maybe we should give a warning?).
;;   (bind (((:slots left right mu sigma mass mean variance) rv))
;;     (flet ((conditional-calc (x left-p)
;;              ;; Return (values pdf xpdf cdf), also for missing
;;              ;; boundary (left-p gives which).  x is the normalized
;;              ;; variable; xpdf is x * pdf, 0 for infinite boundaries.
;;              (if x
;;                  (let* ((x (to-standard-normal x mu sigma))
;;                         (pdf (pdf-standard-normal x))
;;                         (xpdf (* x pdf))
;;                         (cdf (cdf-standard-normal x)))
;;                    (values pdf xpdf cdf))
;;                  (values 0d0 0d0 (if left-p 0d0 1d0)))))
;;       (check-type left truncation-boundary)
;;       (check-type right truncation-boundary)
;;       (bind (((:values pdf-left xpdf-left cdf-left)
;;               (conditional-calc left t))
;;              ((:values pdf-right xpdf-right cdf-right)
;;               (conditional-calc right nil)))
;;         ;; (format t "left  pdf=~a  xpdf=~a  cdf=~a~%right pdf=~a  xpdf=~a  cdf=~a~%"
;;         ;;         pdf-left xpdf-left cdf-left pdf-right xpdf-right cdf-right)
;;         (setf mass (- cdf-right cdf-left))
;;         (unless (plusp mass)
;;           (error "invalid left and/or right boundaries"))
;;         (let ((ratio (/ (- pdf-left pdf-right) mass)))
;;           (setf mean (+ mu (* ratio sigma))
;;                 variance (* (expt sigma 2)
;;                             (- (1+ (/ (- xpdf-left xpdf-right) mass))
;;                                (expt ratio 2)))
;;                 (slot-value rv 'cdf-left) cdf-left)))))
;;   rv)


;; (defmethod cdf ((rv truncated-normal) x)
;;   (check-type x internal-float)
;;   (bind (((:slots-read-only mu sigma mass left right cdf-left) rv))
;;     (cond
;;       ((<* x left) 0d0)
;;       ((>* x right) 1d0)
;;       (t (/ (- (cdf-standard-normal (to-standard-normal x mu sigma)) cdf-left)
;;             mass)))))


;; (defun truncated-normal-left-p (optimal-alpha left right)
;;   "Calculate if it is optimal to use the left-truncated draw and
;; reject than the two-sided accept-reject algorithm."
;;   (> (* optimal-alpha (exp (* optimal-alpha left 0.5d0)) (- right left))
;;      (* (exp 0.5d0) (exp (/ (expt left 2))))))

;; (declaim (inline draw-left-truncated-standard-normal
;;                  draw-left-right-truncated-standard-normal))



;; (defun draw-left-right-truncated-standard-normal (left width coefficient)
;;   "Accept-reject algorithm based on uniforms.  Coefficient is
;; multiplying the exponential, and has to be based on exp(left^2) or
;; exp(right^2) as appropriate.  width is right-left."
;;   (try ((z (+ left (next width rng)))
;;         (rho (* coefficient (exp (* (expt z 2) -0.5d0)))))
;;        (<= (next 1d0 rng) rho) z))

;; (define-cached-slot (rv truncated-normal generator)
;;   (declare (optimize (speed 3)))
;;   (bind (((:slots-read-only mu sigma left right) rv))
;;     (declare (internal-float mu sigma)
;;              (truncation-boundary left right))
;;     (macrolet ((lambda* (form)
;;                  "Lambda with no arguments, transform using mu and sigma."
;;                  `(lambda ()
;;                     (from-standard-normal ,form mu sigma)))
;;                (lambda*- (form)
;;                  "Like lambda*, but also negating the argument."
;;                  `(lambda* (- ,form))))
;;       (cond
;;         ;; truncated on both sides
;;         ((and left right)
;;          (let* ((left (to-standard-normal left mu sigma))
;;                 (right (to-standard-normal right mu sigma))
;;                 (width (- right left))
;;                 (contains-zero-p (<= left 0d0 right)))
;;            (cond
;;              ;; too wide: best to sample from normal and discard
;;              ((and (< (sqrt (* 2 pi)) width) contains-zero-p)
;;               (lambda* (try ((x (draw-standard-normal)))
;;                             (<= left x right) x)))
;;              ;; narrow & contains zero: always use uniform-based reject/accept
;;              (contains-zero-p
;;               (lambda* (draw-left-right-truncated-standard-normal
;;                         left width 1d0)))
;;              ;; whole support above 0, need to test
;;              ((< 0d0 left)
;;               (let ((alpha (truncated-normal-optimal-alpha left)))
;;                 (if (truncated-normal-left-p alpha left right)
;;                     ;; optimal to try and reject if not good
;;                     (lambda* (try ((x (draw-left-truncated-standard-normal
;;                                        left alpha)))
;;                                   (<= x right) x))
;;                     ;; optimal to use the uniform-based reject/accept
;;                     (lambda* (draw-left-right-truncated-standard-normal
;;                               left width (* (expt left 2) 0.5d0))))))
;;              ;; whole support below 0, will flip
;;              (t
;;               ;; swap, and then negate
;;               (let ((left (- right))
;;                     (right (- left)))
;;                 (let ((alpha (truncated-normal-optimal-alpha left)))
;;                   (if (truncated-normal-left-p alpha left right)
;;                       ;; optimal to try and reject if not good
;;                       (lambda*- (try ((x (draw-left-truncated-standard-normal
;;                                           left alpha)))
;;                                      (<= x right) x))
;;                       ;; optimal to use the uniform-based reject/accept
;;                       (lambda*- (draw-left-right-truncated-standard-normal
;;                                  left width (* (expt left 2) 0.5d0))))))))))
;;         ;; truncated on the left
;;         (left
;;          (let ((left (to-standard-normal left mu sigma)))
;;                (if (<= left 0d0)
;;                    (lambda* (try ((x (draw-standard-normal)))
;;                                  (<= left x) x))
;;                    (lambda* (draw-left-truncated-standard-normal
;;                              left
;;                              (truncated-normal-optimal-alpha left))))))
;;         ;; truncated on the right, flip
;;         (right
;;          (let ((left (- (to-standard-normal right mu sigma))))
;;            (if (<= left 0d0)
;;                (lambda*- (try ((x (draw-standard-normal)))
;;                               (<= left x) x))
;;                (lambda*- (draw-left-truncated-standard-normal
;;                           left
;;                           (truncated-normal-optimal-alpha left))))))
;;         ;; this is a standard normal, no truncation
;;         (t (lambda* (draw-standard-normal)))))))
