;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-lisp; Package: CL-USER -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.

(uiop:define-package :distributions.internals
  (:use #:cl
        #:alexandria
        #:let-plus)
  (:export
   #:internal-float
   #:float-vector
   #:as-float
   #:with-floats
   #:as-float-vector
   #:as-float-probabilities
   #:try
   #:maybe-ignore-constant))

(uiop:define-package :distributions
  (:use #:common-lisp
        #:alexandria
        #:anaphora
        #:num-utils.elementwise
        #:num-utils.matrix
        #:num-utils.num=
        #:distributions.internals
	#:special-functions
;        #:select
        #:let-plus)
;;        #:lla)
  (:import-from #:float-features
		#:double-float-nan
		#:double-float-positive-infinity)
  (:shadow #:mean #:variance #:standard-deviation #:factorial #:quantile) ; also in ALEXANDRIA
  ;; continuous-time
  (:export                              ; generators
   #:make-generator
   #:next
   #:generator
   #:transputer
   #:randu
   #:borosh13
   #:waterman14)
  (:export                              ; general interface
   #:draw
   #:generator
   #:mean
   #:variance
   #:cdf
   #:quantile				; also defined in num-utils
   #:log-pdf
   #:pdf)
  (:export                              ; discrete
   #:distinct-random-integers
   #:distinct-random-integers-dense)
  (:export                              ; univariate
   #:standard-deviation
   #:draw-uniform
   #:r-uniform
   #:left
   #:right
   #:r-exponential
   #:rate
   #:draw-standard-exponential
   #:draw-exponential
   #:draw-standard-normal
   #:to-standard-normal
   #:from-standard-normal
   #:r-normal
   #:r-truncated-normal
   #:r-log-normal
   #:log-mean
   #:log-sd
   #:t-scale-to-variance-coefficient
   #:draw-standard-t
   #:r-t
   #:scale
   #:nu

   #:r-gamma
   #:alpha
   #:beta
   #:cdf-gamma
   #:pdf-gamma

   #:r-inverse-gamma
   #:r-chi-square
   #:r-inverse-chi-square
   #:r-beta
   #:draw-rayleigh
   #:r-rayleigh
   #:r-discrete
   #:probabilities
   #:draw-bernoulli
   #:r-bernoulli
   #:draw-binomial
   #:r-binomial
   #:draw-geometric
   #:r-geometric
   #:draw-poisson)
  (:export                              ; continuous-time
   #:r-uniformized-markov-jump)
  ;; (:export
  ;;  #:r-multivariate-normal
  ;;  #:variance-left-sqrt
  ;;  #:r-multivariate-t
  ;;  #:scaling-factor
  ;;  #:s^2
  ;;  #:r-wishart
  ;;  #:scale-left-sqrt
  ;;  #:r-inverse-wishart
  ;;  #:inverse-scale-right-sqrt)
)
