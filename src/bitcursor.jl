# bitcursor.jl
# ===================
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

@inline @generated function Base.convert{N<:Unsigned}(::Type{BitCursor{N}}, idx::Unsigned)
    bs = sizeof(N) * 8
    div = 1 / bs
    mod = bs - 1
    quote
        BitCursor{N}(UInt(floor(idx * $div)), idx & $mod)
    end
end

@inline function BitCursor{N<:Unsigned}(vec::Vector{N})
    return BitCursor{N}(UInt(1))
end

@inline @generated function Base.:(+){N<:Unsigned}(x::BitCursor{N}, nbits::Unsigned)
    bs = sizeof(N) * 8
    div = 1 / bs
    mod = bs - 1
    quote
        incbits = x.bits + nbits
        incchunks = x.chunks + UInt(floor(incbits * $div))
        incbits &= $mod
        BitCursor{N}(incchunks, incbits)
    end
end

@inline function bitidx{N}(x::BitCursor{N})
    return (N * x.chunks) + x.bits
end

@inline function currentword(x::BitCursor)
    return x.chunks + UInt(1)
end
