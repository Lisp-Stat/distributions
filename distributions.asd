;;; -*- Mode: LISP; Base: 10; Syntax: ANSI-Common-Lisp; Package: CL-USER -*-
;;; Copyright (c) 2019-2022 Symbolics Pte. Ltd. All rights reserved.

(asdf:defsystem #:distributions
  :version "1.0.0"
  :license :MS-PL
  :author "Steven Nunez <steve@symbolics.tech>"
  :author "Tamas K Papp <tkpapp@gmail.com"
  :long-name   "Statistical distributions and related functions"
  :description "Random numbers and distributions"
  :long-description  #.(uiop:read-file-string
			(uiop:subpathname *load-pathname* "description.text"))
  :homepage    "https://lisp-stat.dev/docs/manuals/distributions/"
  :source-control (:git "https://github.com/Lisp-Stat/distributions.git")
  :bug-tracker "https://github.com/Lisp-Stat/distributions/issues"
  :depends-on (#:alexandria
	       #:anaphora
	       #:array-operations
	       #:cephes
	       #:num-utils
	       ;;		 #:select		; required by multivariate distributions, not univariate
	       #:special-functions
	       #:let-plus
	       #:float-features)
  :in-order-to ((test-op (test-op "distributions/tests")))
  :serial t
  :pathname #P"src/"
  :components
  ((:file "packages")
   (:file "internals")
   (:file "generator")
   (:file "simple-multiplicative-congruential-generators")
   (:file "defs")
   (:file "generics")
   (:file "discrete")
   (:file "uniform")
   (:file "exponential")
   (:file "normal")
   (:file "log-normal")
   (:file "truncated-normal")
   (:file "t-distribution")
   (:file "gamma")
   (:file "chi-square")
   (:file "beta")
   (:file "rayleigh")
   (:file "bernoulli")
   (:file "binomial")
   (:file "geometric")
   (:file "poisson")))
;; (:file "multivariate")

(asdf:defsystem :distributions/tests
  :description "Unit tests for DISTRIBUTIONS."
  :author "Steven Nunez <steve@symbolics.tech>"
  :author "Tamas K Papp <tkpapp@gmail.com"
  :license "Same as DISTRIBUTIONS, this is part of the DISTRIBUTIONS library."
  :depends-on (#:distributions
	       #:fiveam)
  :pathname #P"tests/"
  :serial t
  :components
  ((:file "test-package")
   (:file "main")
   (:file "normal-tests")
   (:file "t-tests")
   (:file "uniform-tests")
   (:file "exponential-tests")
   (:file "gamma-tests")
   (:file "chi-square-tests")
   (:file "beta-tests")
   (:file "rayleigh-tests")
   (:file "discrete-tests")
   (:file "bernoulli-tests")
   (:file "binomial-tests")
   (:file "geometric-tests")
   (:file "miscellanous-tests"))
  :perform (asdf:test-op (o s)
			 (uiop:symbol-call :fiveam :run! ; this is '#:run! in Fare's Postmodern ASD file
					   (uiop:find-symbol* :all-tests
							      :distributions-tests))))

