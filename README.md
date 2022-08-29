
<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MS-PL License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/lisp-stat/distributions">
    <img src="https://lisp-stat.dev/images/stats-image.svg" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Distributions</h3>

  <p align="center">
  The Distributions package provides a collection of probabilistic distributions and related functions
	<br />
    <a href="https://lisp-stat.dev/docs/manuals/distributions/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/lisp-stat/distributions/issues">Report Bug</a>
    ·
    <a href="https://github.com/lisp-stat/distributions/issues">Request Feature</a>
    ·
    <a href="https://lisp-stat.github.io/distributions/">Reference Manual</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
	<li><a href="#resources">Resources</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About the Project

DISTRIBUTIONS is a library for (1) generating random draws from various
commonly used distributions, and (2) calculating statistical functions,
such as density, distribution and quantiles for these distributions.

In the implementation and the interface, our primary considerations are:

1.  **Correctness.** Above everything, all calculations should be
    correct. Correctness shall not be sacrificed for speed or
    implementational simplicity. Consequently, everything should be
    unit-tested all the time.

2.  **Simple and unified interface.** Random variables are instances
    which can be used for calculations and random draws.  The naming
    convention for building blocks is
    `(draw|cdf|pdf|quantile|...)-(standard-)?distribution-name(possible-suffix)?`,
    eg `pdf-standard-normal` or `draw-standard-gamma1`, for example.

3.  **Speed and exposed building blocks on demand.** You can obtain the generator function for random draws as a closure using the accessor "generator" from an rv.  In addition, the package exports independent building blocks such as draw-standard-normal, which can be inlined into your code if necessary.

Implementation note: Subclasses are allowed to calculate intermediate values (eg to speed up computation) any time, eg right after the initialization of the instance, or on demand.  The consequences or changing the slots of RV classes are UNDEFINED, but probably quite nasty.  Don't do it.  **Note: lazy slots are currently not used, will be reintroduced in the future after profiling/benchmarking.**



### Built With

* [anaphora](https://github.com/tokenrove/anaphora)
* [alexandria](https://gitlab.common-lisp.net/alexandria/alexandria)
* [array-operations](https://github.com/lisp-stat/array-operations)
* [select](https://github.com/lisp-stat/select)
* [let-plus](https://github.com/sharplispers/let-plus)
* [numerical-utilities](https://github.com/lisp-stat/numerical-utilities)
* [cephes](https://github.com/lisp-stat/cephes.cl)
* [special-functions](https://github.com/lisp-stat/special-functions)
* [let-plus](https://github.com/sharplispers/let-plus)
* [float-features](https://github.com/Shinmera/float-features)

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these steps:

### Prerequisites

An ANSI Common Lisp implementation. Developed and tested with [SBCL](https://www.sbcl.org/).

### Installation

Lisp-Stat is composed of several system that are designed to be
independently useful.  So you can, for example, use `distributions` for
any project needing to manipulate statistical distributions.

#### Getting the source

To make the system accessible to [ASDF](https://common-lisp.net/project/asdf/) (a build facility, similar to `make` in the C world), clone the repository in a directory ASDF knows about.  By default the `common-lisp` directory in your home directory is known. Create this if it doesn't already exist and then:

1. Clone the repositories
```sh
cd ~/common-lisp && \
git clone https://github.com/Lisp-Stat/distributions.git && \
```

2. Reset the ASDF source-registry to find the new system (from the REPL)
   ```lisp
   (asdf:clear-source-registry)
   ```
3. Load the system
   ```lisp
   (ql:quickload :distributions)
   ```

This will download all of the dependencies for you.

#### Getting dependencies

To get the third party systems that Lisp-Stat depends on you can use a dependency manager, such as [Quicklisp](https://www.quicklisp.org/beta/) or [CLPM](https://www.clpm.dev/) Once installed, get the dependencies with either of:

```lisp
(clpm-client:sync :sources "clpi") ;sources may vary
```

```lisp
(ql:quickload :distributions)
```

You need do this only once. After obtaining the dependencies, you can
load the system with `ASDF`: `(asdf:load-system :distributions)`.  If
you have installed the slime ASDF extensions, you can invoke this with
a comma (',') from the slime REPL in emacs.

<!-- USAGE EXAMPLES -->
## Usage

Create a standard normal distribution

```lisp
(defparameter *rv-normal* (distributions:r-normal))
```

and take a few draws from it:

```lisp
LS-USER> (distributions:draw *rv-normal*)
1.037208743704438d0
LS-USER> (distributions:draw *rv-normal*)
-0.2847287516046668d0
LS-USER> (distributions:draw *rv-normal*)
-0.6793466378900889d0
LS-USER> (distributions:draw *rv-normal*)
1.5040711441992598d0
LS-USER>
```

For more examples, please refer to the [Documentation](https://lisp-stat.dev/docs/manuals/distributions).


<!-- ROADMAP -->
## Roadmap

1.  Sketch the interface.
2.  Extend basic functionality (see Coverage below)
3.  Keep extending the library based on user demand.
4.  Optimize things on demand, see where the bottlenecks are.

### Specific planned improvements, roughly in order of priority

-   more serious testing. I like the approach in Cook (2006): we should transform empirical quantiles to z-statistics and calculate the p-value using chi-square tests

-   (mm rv x) and similar methods for multivariate normal (and maybe T)

See the [open issues](https://github.com/lisp-stat/distributions/issues) for a list of proposed features (and known issues).


## Coverage

| Distribution  | PDF | CDF | Quantile | Draw | Fit |
|---------------|-----|-----|----------|------|-----|
| Bernoulli     | N/A | N/A | N/A      | Yes  | No  |
| Beta          | Yes | Yes | Yes      | Yes  | Yes |
| Binomial      | No  | No  | No       | Yes  | No  |
| Chi-Square    | No  | No  | No       | No   | No  |
| Discrete      | Yes | Yes | No       | Yes  | No  |
| Exponential   | Yes | Yes | Yes      | Yes  | No  |
| Gamma         | Yes | Yes | Yes      | Yes  | No  |
| Geometric     | No  | No  | No       | Yes  | No  |
| Inverse-Gamma | Yes | No  | No       | Yes  | No  |
| Log-Normal    | Yes | Yes | Yes      | Yes  | No  |
| Normal        | Yes | Yes | Yes      | Yes  | No  |
| Poisson       | No  | No  | No       | Yes  | No  |
| Rayleigh      | No  | Yes | No       | Yes  | No  |
| Student t     | No  | No  | No       | Yes  | No  |
| Uniform       | Yes | Yes | Yes      | Yes  | No  |




## Resources

This system is part of the [Lisp-Stat](https://lisp-stat.dev/) project; that should be your first stop for information. Also see the [resources](https://lisp-stat.dev/resources) and [community](https://lisp-stat.dev/community) page for more
information.

<!-- CONTRIBUTING -->
## Contributing

Always try to implement state-of-the-art generation and calculation methods. If you need something, read up on the literature, the field has developed a lot in the last decades, and most older books present obsolete methods. Good starting points are Gentle (2005) and Press et al (2007), though you should use the latter one with care and don't copy algorithms without reading a few recent articles, they are not always the best ones (the authors admit this, but they claim that some algorithms are there for pedagogical purposes).

Always document the references in the docstring, and include the full citation in doc/references.bib (BibTeX format).

Do at least basic optimization with declarations (eg until SBCL doesn't give a notes any more, notes about return values are OK). Benchmarks are always welcome, and should be documented.

Document doubts and suggestions for improvements, use `!!` and `??`, more marks mean higher priority.

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on the code of conduct, and the process for submitting pull requests.

<!-- LICENSE -->
## License

Distributed under the MS-PL License. See [LICENSE](LICENSE) for more information.



<!-- CONTACT -->
## Contact

Project Link: [https://github.com/lisp-stat/distributions](https://github.com/lisp-stat/distributions)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/lisp-stat/distributions.svg?style=for-the-badge
[contributors-url]: https://github.com/lisp-stat/distributions/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/lisp-stat/distributions.svg?style=for-the-badge
[forks-url]: https://github.com/lisp-stat/distributions/network/members
[stars-shield]: https://img.shields.io/github/stars/lisp-stat/distributions.svg?style=for-the-badge
[stars-url]: https://github.com/lisp-stat/distributions/stargazers
[issues-shield]: https://img.shields.io/github/issues/lisp-stat/distributions.svg?style=for-the-badge
[issues-url]: https://github.com/lisp-stat/distributions/issues
[license-shield]: https://img.shields.io/github/license/lisp-stat/distributions.svg?style=for-the-badge
[license-url]: https://github.com/lisp-stat/distributions/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/symbolics/
