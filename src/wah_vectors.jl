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

const I32 = 1.0 / 32.0
const ALL_ONES = 0xFFFFFFFF
const ALL_ZEROS = 0x00000000

@inline function append_literal!(vec::Vector{UInt32}, element::WAHElement,
                                 idx::UInt64, tailspace::UInt64)

    element = UInt32(element)

    # Assume tail_space can never be 0.
    # When we fill the tail, with a 31 bit literal, there are 3 possible cases:
    #
    # 1). We add 31 bits to the tail, and there is still room in the tail for
    # 1 more bit (tail_space == 32).
    #
    # 2). We add 31 bits to the tail, and there is no room in the tail for any
    # more bits (tail_space == 31).
    #
    # 3). We add as many bits as possible to the tail, but still have some to
    # carry to the new tail (1 <= tail_space < 31).

    # Fill current tail:
    # Consider an example literal of 0x7FFFFFFF,
    # If case 1, value will be 0xfffffffe.
    # If case 2, value will be 0x7FFFFFFF.
    # If case 3, value will be whatever fits in the remaining tail_space.
    vec[idx] |= (element >> (UInt64(32) - tailspace - UInt64(1)))

    # Fill next tail, if applicable:
    # If case 1, idx will not increase, `element << (tail_space + 1)` will be 0.
    # If case 2, idx will increase by 1, `element << (tail_space + 1)` will be 0.
    # If case 3, idx will increase by 1, `element << (tail_space + 1)` will not be 0.
    idx = ifelse(tailspace == UInt64(32), idx, idx + UInt64(1))
    vec[idx] |= (element << (tailspace + 1))

    return idx, ifelse(tailspace == UInt64(32), UInt64(1), tailspace + UInt64(1))
end

@inline function append_run!(vec::Vector{UInt32}, element::WAHElement,
                             idx::UInt64, tailspace::UInt64)

    # `nb`: How many bits we have to add to the vector.
    # We know at the very least this value is 62 bits, if you make the
    # assumption that 1 word run elements are not possible.

    # Note, must use UInt64 as the max number of bits a WAH run element can contain
    # is 33285996513 or 0x7BFFFFFE1 which needs a 64 bit integer to represent it.
    nb = UInt64(31) * UInt64(nruns(element))
    bitval = ifelse(is_ones_runs(element), ALL_ONES, ALL_ZEROS)

    # Fill the current tail with bits, calculate how many bits we now have, and
    # increase idx.
    vec[idx] |= (bitval >> (32 - tailspace))
    nb -= tailspace
    idx += 1

    # Now we calculate how many full _32 BIT_ elements we need to add, and how
    # many bits will be left.
    nfull = UInt64(floor(nb * I32))
    nb = nb & UInt64(31)                 # Fast modulus.

    # Now we actually add the full elements.
    last = (idx + nfull) - UInt64(1)
    vec[idx:last] = bitval

    # Now we've added the full elements, we need to add a tail and fill it
    # with what is left.
    idx = last + UInt64(1)
    newtail = 32 - nb
    vec[idx] = (bitval << newtail)

    return idx, newtail
end


function Base.convert(::Type{Vector{UInt32}}, vec::WAHVector)
    result = zeros(UInt32, vec.nwords)
    ridx = UInt64(1)
    freebits = UInt64(32)
    for element in vec.data
        if isruns(element)
            ridx, freebits = append_run!(result, element, ridx, freebits)
        else
            ridx, freebits = append_literal!(result, element, ridx, freebits)
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

function Base.show(io::IO, x::WAHVector)
    println("$(length(x))-element WAHVector storing $(nwords(x)) words:")
    for element in x.data
        show(io, element)
    end
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
