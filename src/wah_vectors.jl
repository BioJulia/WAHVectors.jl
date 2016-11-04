# WAH Vectors
# ===========
#
# Construction of a WAHVectors.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

# Type definition
# ---------------

type WAHVector
    data::Vector{WAHElement}
    nwords::UInt64
end

# Constructors
# ------------

function WAHVector()
    return WAHVector(Vector{WAHElement}(0), UInt64(0))
end

function WAHVector(vec::Vector{UInt32})
    return WAHVector(convert(Vector{WAHElement}, vec), length(vec))
end

function WAHVector(element::WAHElement)
    d = Vector{WAHElement}(0)
    push!(d, element)
    return WAHVector(d, UInt64(nwords(element)))
end

# Exported operations
# -------------------

nwords(vec::WAHVector) = vec.nwords
nbits(vec::WAHVector) = 31 * nwords(vec)

const I32 = 1.0/32.0
const ALL_ONES = 0xFFFFFFFF
const ALL_ZEROS = 0x00000000

@inline function set_ints!(vec::Vector{UInt32}, idx::UInt64, element::WAHElement)
    if isruns(element)
        # Work out the number of integers required.
        nb = Int64(nbits(element))
        nout = UInt64(floor(nb * I32))
        val = ifelse(is_ones_runs(element), ALL_ONES, ALL_ZEROS)
        last = (idx + nout) - UInt64(1)
        result[idx:last] = val
        idx = last

        leftover_bits = Int64(nb & 31) # Quick modulus of nb mod 32.
        leftover_val = val

    else
        vec[idx] = UInt32(element)
        # Still 1 bit free in result.
        # We return the same index as the last bit needs to be filled
        # on the next iteration.
        leftover_bits = -1
        leftover_val = ALL_ZEROS
    end
    return idx, leftover_bits, leftover_val
end


@inline function append_literal!(vec::Vector{UInt32}, element::WAHElement,
                                 idx::Int64, tail_space::Int64)
    element = UInt32(element)
    # We need to use the current element to fill any bits that are unused in
    # the vector of UInt32.
    jump = UInt64(32) - tail_space
    val = element >> jump
    vec[idx] |= val
    # Now we need to get the remainder and stick it on the end as the new tail.
    idx += UInt32(1)
    vec[idx] = element << jump          ### THIS IS WRONG, IT SHOULD BE 32 - jump??!
    return idx, UInt64(32) - jump
end

@inline function append_run!(vec::Vector{UInt32}, element::WAHElement,
                             idx::UInt64, tail_space::UInt64)
    # We need to use the current element to fill any bits that are unused in the
    # tail of vector UInt32, and then go to the next element.
    val = ifelse(is_ones_runs(element), ALL_ONES >> (32 - tail_space), ALL_ZEROS)
    vec[idx] |= val
    idx += 1
    # Next we calculate how many full elements we need to add.
    nb = UInt64(nbits(element)) - tail_space
    nout = UInt64(floor(nb * I32))
    val = ifelse(is_ones_runs(element), ALL_ONES, ALL_ZEROS)
    last = (idx + nout) - UInt64(1)
    vec[idx:last] = val
    # Now we've added the full elements, we need to add a tail and fill it
    # with what is left.
    idx = last + UInt64(1)
    tail_space = nb & UInt64(31) # Quick modulus 32.
    vec[idx] = ifelse(is_ones_runs(element), ALL_ONES << (32 - tail_space), ALL_ZEROS)

    return idx,
end


function Base.convert(::Type{Vector{UInt32}}, vec::WAHVector)
    result = Vector{UInt32}(vec.nwords)
    result_idx = UInt64(1)
    rem_bits = UInt64(32)
    for i in 2:endof(vec.data)
        element = vec.data[i]
        if isruns(element)
            result_idx, rem_bits = append_runs!(result, element, result_idx, rem_bits)
        else
            result_idx, rem_bits = append_literal!(result, element, result_idx, rem_bits)
        end
    end
    return result
end



@inline function Base.push!(vec::WAHVector, element::WAHElement)
    if length(vec.data) > 0
        append!(vec, element)
    else
        push!(vec.data, element)
        vec.nwords += UInt64(nwords(element))
    end
end

function Base.:&(x::WAHVector, y::WAHVector)
    xc = WAHCursor(x)
    yc = WAHCursor(y)
    result = WAHVector()
    #decode!(xcursor)
    #decode!(ycursor)
    push!(result.data, xc & yc)
    while (xc.word_i <= xc.len) && (yc.word_i <= yc.len)
        check_to_move!(xc)
        check_to_move!(yc)
        append!(result, xc & yc)
    end
    return result
end

# Non-Exported operations
# -----------------------

@inline function append!(vec::WAHVector, element::WAHElement)
    if isliteral(element)
        append_literal!(vec.data, element)
        vec.nwords += UInt64(1)
    else
        append_run!(vec.data, element)
        vec.nwords += UInt64(ncomp(element))
    end
end
