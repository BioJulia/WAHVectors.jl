# WAHVectors.jl

## Description
Compress bit vectors using the Word Aligned Hybrid method.

**This package is currently (pre)alpha stage**

Although bit vectors can be compressed with standard run-length encoding (RLE),
If you are using bit vectors to represent some kinds of data, for example genotype data for biology,
bitwise logical operations require that the bits associated with variants be aligned.
This is difficult to ensure with RLE.

The Word Aligned Hybrid encoding strategy, represents run lengths in words rather than bits.

The difference between the RLE and WAH encoding strategies are explained by [R.M. Layer *et al.* (2016)](http://www.nature.com/nmeth/journal/v13/n1/full/nmeth.3654.html) as follows:

> RLE encodes stretches of identical val- ues (‘runs’) as a new value in which the first bit indicates the run value and the remaining bits give the number of bits in the run.
> WAH is similar to RLE, except that it uses two different types of values.
> The ‘fill’ type encodes runs of identical values, and the ‘literal’ type encodes uncompressed binary.
> This hybrid approach addresses an inefficiency in RLE in which short runs map to larger encoded values.
> The first bit in a WAH value indicates whether it is fill (1) or literal (0).
> For a fill value, the second bit gives the run value and the remaining bits give the run length in words (not bits, like in RLE).
> For a literal value, the remaining bits directly encode the uncompressed input.
> As each WAH-encoded value represents some number of words, and as bitwise logical operations are performed between words, these operations can be performed directly on compressed values.

## Badges

Get Help: [![Join the chat at Gitter!](https://badges.gitter.im/BioJulia.png)](https://gitter.im/BioJulia/WAHVectors.jl)
[![reference docs](https://img.shields.io/badge/docs-reference-blue.svg)](http://biojulia.github.io/WAHVectors.jl/latest/)

Code Quality: [![Build Status](https://travis-ci.org/BioJulia/WAHVectors.jl.svg?branch=master)](https://travis-ci.org/BioJulia/WAHVectors.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/5x7boks0y8llvkwc?svg=true)](https://ci.appveyor.com/project/Ward9250/wahvectors-jl)
[![codecov.io](http://codecov.io/github/BioJulia/WAHVectors.jl/coverage.svg?branch=master)](http://codecov.io/github/BioJulia/WAHVectors.jl?branch=master)
