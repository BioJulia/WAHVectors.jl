# WAH Elements
# ============
#
# The individual elements of a WAHVector.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

# The WAHElement type and constants
# ---------------------------------

primitive type WAHElement 32 end
Base.convert(::Type{WAHElement}, x::UInt32) = reinterpret(WAHElement, x)
Base.convert(::Type{UInt32}, x::WAHElement) = reinterpret(UInt32, x)

WAHElement(x::UInt32) = convert(WAHElement, x)
function WAHElement(value::UInt32, nruns::UInt32)
    @assert nwords <= WAH_MAX_NRUNS "nruns is too big"
    return WAHElement(((0x00000002 + value) << 30) + nwords)
end

const WAH_LITERAL_ZEROS = convert(WAHElement, 0x00000000)
const WAH_LITERAL_ONES = convert(WAHElement, 0x7FFFFFFF)

const WAH_FULL_ZEROS = convert(WAHElement, 0xBFFFFFFF)
const WAH_FULL_ONES = convert(WAHElement, 0xFFFFFFFF)
const WAH_MAX_NRUNS = 0x3FFFFFFF

# Basic general operations on WAHElements
# ---------------------------------------

Base.:(==)(x::WAHElement, y::WAHElement) = convert(UInt32, x) == convert(UInt32, y)

# Basic operations
#-----------------

"""
    isruns(x::WAHElement)

Return `true` if the element of the WAH compressed bit array `x`
represents a compressed run of words. Otherwise return `false`.
"""
isruns(x::WAHElement) = convert(UInt32, x) ≥ 0x80000000

"""
    is_zeros_runs(x::WAHElement)

Return `true` if the WAH Element represents a compressed run of all zero words.
"""
is_zeros_runs(x::WAHElement) = 0xC0000000 > convert(UInt32, x) ≥ 0x80000000

"""
    is_ones_runs(x::WAHElement)

Return `true` if the WAH Element represents a compressed run of all one words.
"""
is_ones_runs(x::WAHElement) = convert(UInt32, x) ≥ 0xC0000000




"""
    isliteral(x::WAHElement)

Return `true` if the element of the WAH compressed bit array `x`
represents a literal word rather than a compressed run of words, in
which case this function will return `false`.
"""
isliteral(x::WAHElement) = convert(UInt32, x) < 0x80000000



"""
    nwords(x::WAHElement)

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
    runval(x::WAHElement)

Get the runvalue of a compressed WAHElement.

!!! warning
    Output will not make sense if you use it on a WAH element that
    represents a literal word (i.e. `isliteral(x)` returns `true`) rather
    than a number of compressed words.
"""
runval(x::WAHElement) = (convert(UInt32, x) & 0x40000000) >> 30

"""
    nruns(x::WAHElement)

Get the number of words represented by this single WAHElement, assuming it
is a compressed element.

!!! warning
    Output will not make sense if you use it on a WAH element that
    represents a literal word (i.e. `isliteral(x)` returns `true`) rather
    than a number of compressed words.
"""
nruns(x::WAHElement) = convert(UInt32, x) & WAH_MAX_NRUNS

"""
    nfree(x::WAHElement)

Return how many more words this WAHElement can compress into it.

!!! warning
    Output will not make sense if you use it on a WAH element that
    represents a literal word (i.e. `isliteral(x)` returns `true`) rather
    than a number of compressed words.
"""
nfree(x::WAHElement) = WAH_MAX_NRUNS - nruns(x)

"""
    isfull(x::WAHElement)

Check whether this WAHElement contains as many words as it can.

!!! warning
    Output will not make sense if you use it on a WAH element that
    represents a literal word (i.e. `isliteral(x)` returns `true`) rather
    than a number of compressed words.
"""
isfull(x::WAHElement) = (x == WAH_FULL_ZEROS) || (x == WAH_FULL_ONES)

matchingfills(x::WAHElement, y::WAHElement) = (convert(UInt32, x) >> 30) == (convert(UInt32, y) >> 30)

hasroom(x::WAHElement) = nruns(x) < WAH_MAX_NRUNS
hasroom(x::WAHElement, required::UInt32) = (nruns(x) + required) < WAH_MAX_NRUNS

increment_nruns_unsafe(x::WAHElement) = WAHElement(convert(UInt32, x) + 0x00000001)
increment_nruns_unsafe(x::WAHElement, y::UInt32) = WAHElement(convert(UInt32, x) + y)

@inline function runfill(x::WAHElement)
    return ifelse(isruns(x), ifelse(is_ones_runs(x), 0x7FFFFFFF, 0x00000000), convert(UInt32, x))
end

nbits(x::WAHElement) = UInt64(31) * UInt64(nwords(x))

function Base.show(io::IO, element::WAHElement)
    rf = string(runfill(element), base = 16, pad = 2)
    if isruns(element)
        println(io, "$(nruns(element)) x $rf")
    else
        println(io, "1 x $rf")
    end
end
