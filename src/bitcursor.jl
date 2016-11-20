# bitcursor.jl
# ============
#
# A type for tracking the current position when moving across a bitvector.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

# A cursor to track bit position in an array of unsigned integers.
immutable BitCursor{N<:Unsigned}
    chunks::UInt
    bits::UInt
end

# Internal functions for generated functions
# ------------------------------------------

@inline function _numbits{T<:Unsigned}(::Type{T})
    return sizeof(T) * 8
end

@inline function _makedivmod{T<:Unsigned}(::Type{T})
    bs = _numbits(T)
    return 1 / bs, bs - 1
end

@inline @generated function Base.convert{N<:Unsigned}(::Type{BitCursor{N}}, idx::Unsigned)
    div, mod = _makedivmod(N)
    quote
        BitCursor{N}(UInt(floor(idx * $div)), idx & $mod)
    end
end

@inline function BitCursor{N<:Unsigned}(vec::Vector{N})
    return BitCursor{N}(UInt(1))
end

@inline @generated function bitidx{N}(x::BitCursor{N})
    bs = _numbits(N)
    quote
        return ($bs * chunks(x)) + x.bits
    end
end

@inline function chunks(x::BitCursor)
    return x.chunks
end

@inline function bits(x::BitCursor)
    return x.bits
end

@inline @generated function goforward{N<:Unsigned}(x::BitCursor{N}, nbits::Unsigned)
    div, mod = _makedivmod(N)

    quote
        incbits = bits(x) + nbits
        incchunks = chunks(x) + UInt(floor(incbits * $div))
        incbits &= $mod
        return BitCursor{N}(incchunks, incbits)
    end
end

@inline @generated function goforward{N<:Unsigned}(x::BitCursor{N}, y::BitCursor{N})
    div, mod = _makedivmod(N)

    quote
        bitsum = bits(x) + bits(y)
        chunksum = chunks(x) + chunks(y) + UInt(floor(bitsum * $div))
        bitsum &= $mod
        return BitCursor{N}(chunksum, bitsum)
    end
end

@inline function Base.:(+)(x::BitCursor, y::UInt)
    return goforward(x, y)
end

@inline function Base.:(+)(x::BitCursor, y::BitCursor)
    return goforward(x, y)
end
