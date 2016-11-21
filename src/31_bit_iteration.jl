# each_word_iteration.jl
# ======================
#
# An iterator over arrays of binary fetching 31 bits at a time.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

immutable Every31Bits{T}
    data::T
end

# General methods.

Base.eltype(iter::Every31Bits)= UInt32

@inline function Base.start(iter::Every31Bits)
    return 1
end

# Specific methods.

# BitVectors.

@inline function Base.next(iter::Every31Bits{BitVector}, state::Int)
    chunk = 0x00000000
    lv = length(iter.data)
    niter = ifelse(lv >= (state + 30), 31, (lv - state) + 1)
    @inbounds for i in 1:niter
        bit_i = UInt32(iter.data[state])
        chunk |= (bit_i << (31 - i))
        state += 1
    end
    return chunk, state
end

@inline function Base.done(iter::Every31Bits{BitVector}, state::Int)
    return state > length(iter.data)
end

@inline function Base.length(iter::Every31Bits{BitVector})
    return UInt64(ceil(length(iter.data) / 31))
end

# WAHVectors

@inline function Base.start(iter::Every31Bits{WAHVector})
    return (1,nwords(iter.data.data[1]))
end

@inline function Base.next(iter::Every31Bits{WAHVector}, state)
    elem = iter.data.data[state[1]]
end

@inline function Base.length(iter::Every31Bits{WAHVector})
    return nwords(iter.data)
end
