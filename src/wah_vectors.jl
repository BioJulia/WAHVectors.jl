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

function Base.convert(::Type{Vector{UInt32}}, vec::WAHVector)
    result = Vector{UInt32}(vec.nwords)
    result_idx = UInt64(1)

    result_idx, rem_bits, rem_val = set_ints!(result, result_idx, vec.data[1])

    for element in vec.data[2:endof(vec.data)]

        #if rem_bits < 0
            # IF rem_bits < 0, remember that you have no rem_val to deal with.
            if isruns(element)

                # Put the mising bit in the remaining space.
                val = ifelse(is_ones_runs(element), ALL_ONES >> (32 - rem_bits), ALL_ZEROS)
                result[result_idx] |= val
                # Once result_idx is full we go to the next element.
                result_idx += 1

                # Calculating how many elements we need to fill.
                nb = Int64(nbits(element)) - rem_bits
                nout = UInt64(floor(nb * I32))

                val = ifelse(is_ones_runs(element), ALL_ONES, ALL_ZEROS)
                last = (result_idx + nout) - UInt64(1)
                result[result_idx:last] = val
                result_idx = last + UInt64(1)

                # Get leftover values with modulus 32.
                rem_bits = Int64(nb & 31) # Quick modulus of nb mod 32.
                result[result_idx] =
                    ifelse(is_ones_runs(element), ALL_ONES << (32 - rem_bits), ALL_ZEROS)


            else

                ielement = UInt32(element) # Element is non-compressed 31 bit literal.
                jump = 32 - rem_bits
                val = ielement >> jump
                result[result_idx] |= val
                result_idx += 1
                result[result_idx] = ielement << jump

                # How many elements we have left.
                rem_bits = 32 - jump

            end
        #else

        #end




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
