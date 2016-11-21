# bitcursor.jl
# ============
#
# A type for tracking the current position when moving across a bitvector.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

# Internal functions for generated functions
# ------------------------------------------

@inline function _numbits{U<:Unsigned}(::Type{U})
    return sizeof(U) * 8
end

@inline function _makedivmod{U<:Unsigned}(::Type{U})
    bs = _numbits(U)
    return 1 / bs, bs - 1
end

@inline function _fastdiv(a, b)
    return UInt(floor(a * b))
end

# The BitCursor Type
# ------------------

# A cursor to track bit position in an array of unsigned integers.
immutable BitCursor{U<:Unsigned}
    chunks::UInt
    bits::UInt
end

@inline @generated function Base.convert{U<:Unsigned}(::Type{BitCursor{U}}, idx::Unsigned)
    div, mod = _makedivmod(U)
    quote
        BitCursor{U}(_fastdiv(idx, $div), idx & $mod)
    end
end

@inline function BitCursor{U<:Unsigned}(vec::Vector{U})
    return BitCursor{U}(UInt(1))
end

@inline @generated function bitidx{U}(x::BitCursor{U})
    bs = _numbits(U)
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

@inline @generated function goforward{U<:Unsigned}(x::BitCursor{U}, nbits::Unsigned)
    div, mod = _makedivmod(U)

    quote
        incbits = bits(x) + nbits
        incchunks = chunks(x) + _fastdiv(incbits, $div)
        incbits &= $mod
        return BitCursor{U}(incchunks, incbits)
    end
end

@inline @generated function goforward{U<:Unsigned}(x::BitCursor{U}, y::BitCursor{U})
    div, mod = _makedivmod(U)

    quote
        bitsum = bits(x) + bits(y)
        chunksum = chunks(x) + chunks(y) + _fastdiv(bitsum, $div)
        bitsum &= $mod
        return BitCursor{U}(chunksum, bitsum)
    end
end

@inline function Base.:(+)(x::BitCursor, y::UInt)
    return goforward(x, y)
end

@inline function Base.:(+)(x::BitCursor, y::BitCursor)
    return goforward(x, y)
end

@inline function current_chunk(x::BitCursor)
    return chunks(x) + 1
end

@inline function get_chunk{U<:Unsigned}(vec::Vector{U}, pos::BitCursor{U})
    return vec[current_chunk(pos)]
end

"""
    mask_msb2bit(x::BitCursor{U})

Mask the bits in a chunk upto and including the bit pointed at by
the BitCursor, `x`.
"""
@inline @generated function mask_msb2bit{U<:Unsigned}(x::BitCursor{U})
    tm = typemax(U)

    quote
        return ~($tm >>> x.bits)
    end
end

"""
    mask_bit2lsb(x::BitCursor{U})

Mask the bits in a chunk from and including the bit pointed at by the
BitCursor `x`, until the end of the chunk.
"""
@inline @generated function mask_bit2lsb{U<:Unsigned}(x::BitCursor{U})
    tm = typemax(U)
    one = U(1)

    quote
        return $tm >>> (x.bits - $one)
    end
end
