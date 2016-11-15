# WAH Elements
# ============
#
# The individual elements of a WAHVector.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

# The WAHElement type and constants
# ---------------------------------

bitstype 32 WAHElement
Base.convert(::Type{WAHElement}, x::UInt32) = reinterpret(WAHElement, x)
Base.convert(::Type{UInt32}, x::WAHElement) = reinterpret(UInt32, x)

function WAHElement(value::UInt32, nwords::UInt32)
    return WAHElement(((0x00000002 + value) << 30) + nwords)
end

const WAH_LITERAL_ZEROS = WAHElement(0x00000000)
const WAH_LITERAL_ONES = WAHElement(0x7FFFFFFF)

const WAH_FULL_ZEROS = WAHElement(0xBFFFFFFF)
const WAH_FULL_ONES = WAHElement(0xFFFFFFFF)
const WAH_MAX_NWORDS = 0x3FFFFFFF

# Basic general operations on WAHElements
# ---------------------------------------

Base.:(==)(x::WAHElement, y::WAHElement) = UInt32(x) == UInt32(y)

# Basic operations
#-----------------

"""
    isruns(x)

Return `true` if the element of the WAH compressed bit array `x`
represents a compressed run of words. Otherwise return `false`.
"""
isruns(x::WAHElement) = UInt32(x) >= 0x80000000

"""
    isliteral(x)

Return `true` if the element of the WAH compressed bit array `x`
represents a literal word rather than a compressed run of words, in
which case this function will return `false`.
"""
isliteral(x::WAHElement) = UInt32(x) < 0x80000000

"""
    is_zeros_runs(x)

Return `true` if the WAH Element represents a compressed run of all zero words.
"""
is_zeros_runs(x::WAHElement) = isruns(x) && (UInt32(x) < 0xC0000000)

"""
    is_ones_runs(x)

Return `true` if the WAH Element represents a compressed run of all one words.
"""
is_ones_runs(x::WAHElement) = UInt32(x) >= 0xC0000000

"""
    nwords(x)

Get the number of words represented by this single WAHElement.
"""
@inline function nwords(x::WAHElement)
    if isruns(x)
        return nruns(x)
    else
        return 0x00000001
    end
end

"""
    runval(x)

Get the runvalue of a compressed WAHElement.

**Note:** This will not make sense if you use it on a WAH element that
represents a literal word (i.e. `isliteral(x)` returns `true`) rather
than a number of compressed words.
"""
runval(x::WAHElement) = (UInt32(x) & 0x40000000) >> 30

"""
    nruns(x)

Get the number of words represented by this single WAHElement, assuming it
is a compressed element.

**Note:** This will not make sense if you use it on a WAH element that
represents a literal word (i.e. `isliteral(x)` returns `true`) rather
than a number of compressed words.
"""
nruns(x::WAHElement) = UInt32(x) & WAH_MAX_NWORDS

"""
    nfree(x)

Return how many more words this WAHElement can compress into it.

**Note:** This will not make sense if you use it on a WAH element that
represents a literal word (i.e. `isliteral(x)` returns `true`) rather
than a number of compressed words.
"""
nfree(x::WAHElement) = WAH_MAX_NWORDS - nruns(x)

"""
    isfull(x)

Check whether this WAHElement contains as many words as it can.

**Note:** This will not make sense if you use it on a WAH element that
represents a literal word (i.e. `isliteral(x)` returns `true`) rather
than a number of compressed words.
"""
isfull(x::WAHElement) = (x == WAH_FULL_ZEROS) || (x == WAH_FULL_ONES)

matchingfills(x::WAHElement, y::WAHElement) = (UInt32(x) >> 30) == (UInt32(y) >> 30)

hasroom(x::WAHElement) = nruns(x) < WAH_MAX_NWORDS
hasroom(x::WAHElement, required::UInt32) = (nruns(x) + required) < WAH_MAX_NWORDS

increment_nruns_unsafe(x::WAHElement) = WAHElement(UInt32(x) + 0x00000001)
increment_nruns_unsafe(x::WAHElement, y::UInt32) = WAHElement(UInt32(x) + y)

@inline function runfill(x::WAHElement)
    return ifelse(isruns(x), ifelse(is_ones_runs(x), 0x7FFFFFFF, 0x00000000), UInt32(x))
end

nbits(x::WAHElement) = UInt64(31) * UInt64(nwords(x))

function Base.show(io::IO, element::WAHElement)
    if isruns(element)
        println(io, "$(nruns(element)) compressed $(runfill(element)) words.")
    else
        println(io, "1 literal $(runfill(element)).")
    end
end
