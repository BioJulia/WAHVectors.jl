# WAH Elements
# ============
#
# Individual elements of a WAHVector.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

# The WAHElement type and constants
# ---------------------------------

bitstype 32 WAHElement
Base.convert(WAHElement, x::UInt32) = reinterpret(WAHElement, x)

const WAH_COMPRESSED_MASK = WAHElement(0x80000000)

# Basic operations on WAHElements
# ------------------------------

@inline function Base.:&(x::WAHElement, y::WAHElement)
    return reinterpret(WAHElement, reinterpret(UInt32, x) & reinterpret(UInt32, y))
end
@inline function Base.:&(x::WAHElement, y::UInt32)
    return reinterpret(WAHElement, reinterpret(UInt32, x) & y)
end
@inline function Base.:&(x::UInt32, y::WAHElement)
    return reinterpret(WAHElement, x & reinterpret(UInt32, y))
end

@inline function Base.:+(x::WAHElement, y::UInt32)
    return reinterpret(WAHElement, reinterpret(UInt32, x) + y)
end

Base.:+(x::UInt32, y::WAHElement) = y + x

@inline function Base.:>=(x::WAHElement, y::UInt32)
    return reinterpret(UInt32, x) >= y
end

@inline function Base.:>=(x::UInt32, y::WAHElement)
    return x >= reinterpret(UInt32, y)
end

@inline function Base.:<=(x::WAHElement, y::UInt32)
    return reinterpret(UInt32, x) <= y
end

@inline function Base.:<=(x::UInt32, y::WAHElement)
    return x <= reinterpret(UInt32, y)
end

"""
    iszeros(x)

Return `true` if the WAH Element represents a run of zeros.
"""
@inline function iszeros(x::WAHElement)
    (x >= 0x80000000) && (x < 0xC0000000)
    return reinterpret(UInt32, x) >= 0x80000000 &&
end

@inline function isones(x::WAHElement)

end

#@inline function hasspace(x::WAHElement)
#    return reinterpret(UInt32, x) <
#end








"""
    iscompressed(x)

Return `true` if the element of the WAH compressed bit array `x`
represents a compressed run of words. Otherwise return `false`.
"""
@inline function iscompressed(x::WAHElement)
    return (x & WAH_COMPRESSED_MASK) == WAH_COMPRESSED_MASK
end

"""
    isliteral(x)

Return `true` if the element of the WAH compressed bit array `x`
represents a literal word rather than a compressed run of words, in
which case this function will return `false`.
"""
@inline function isliteral(x::WAHElement)
    return !iscompressed(x)
end

"""
    runvalue(x)

Get the runvalue of a compressed WAHElement.

**Note:** This will not make sense if you use it on a WAH element that
represents a literal word (i.e. `isliteral(x)` returns `true`) rather
than a number of compressed words.
"""
@inline function runvalue(x::WAHElement)
    return reinterpret(UInt32, x & 0x40000000) >> 30
end

"""
    nwords(x)

Get the number of words represented by this single WAHElement.
"""
@inline function nwords(x::WAHElement)
    return reinterpret(UInt32, x & 0x3FFFFFFF)
end
