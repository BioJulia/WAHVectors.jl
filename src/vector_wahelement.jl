# Vector{WAHElement}
# ==================
#
# Operations on vectors of WAHElement
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

"""
    convert(Vector{WAHElement}, arr)

Create a Vector of WAHElement from a Vector of UInt32.
"""
function Base.convert(::Type{Vector{WAHElement}}, arr::Vector{UInt32})
    n_cmp = (x[1] & UInt32(1)) << 30
    t_cmp = x[1] >> 1
    v = Vector{WAHElement}(0)
    push!(v, t_cmp)
    @inbounds for i in 2:endof(x)
        t_cmp = x[i] >> 1
        t_cmp = t_cmp | n_cmp
        append_literal!(v, WAHElement(t_cmp))
        n_cmp = (x[i] & UInt32(1)) << 30
    end
    return v
end

"""
    append_literal!(a, element)

Append a WAHElement representing a literal binary value to a Vector{WAHElement}.

**Note:** This method takes your word for it that A). You are appending i.e.
the Vector{WAHElement} is not empty, and B).
That the value you are appending IS in fact a WAHElement for which the
`isliteral` method returns `true`. As a result, this method is designed for
internal use only.
"""
@inline function append_literal!(vec::Vector{WAHElement}, element::WAHElement)
    tail = vec[endof(vec)]
    if element == WAH_LITERAL_ZEROS
        if tail == WAH_LITERAL_ZEROS
            vec[endof(vec)] = WAHElement(0x80000002)
        elseif isruns(tail) && (UInt32(tail) < 0xBFFFFFFF)
            vec[endof(vec)] = increment_nruns_unsafe(tail)
        else
            push!(vec, element)
        end
    elseif element == WAH_LITERAL_ONES
        if tail == WAH_LITERAL_ONES
            vec[endof(vec)] = WAHElement(0xC0000002)
        elseif is_ones_runs(tail) && (UInt32(tail) < 0xFFFFFFFF)
            vec[endof(vec)] = increment_nruns_unsafe(tail)
        else
            push!(vec, element)
        end
    else
        push!(vec, element)
    end
end

"""
    append_run!(a, element)

Append a WAHElement representing a literal binary value to a Vector{WAHElement}.

**Note:** This method takes your word for it that A). You are appending i.e.
the Vector{WAHElement} is not empty, and B).
That the value you are appending IS in fact a WAHElement for which the
`isruns` method returns `true`. As a result, this method is designed for
internal use only.
"""
@inline function append_run!(vec::Vector{WAHElement}, element::WAHElement)
    fillsize = nruns(element)
    if matchingfills(tail, element) && hasroom(tail, fillsize)
        vec[endof(vec)] += fillsize
    else
        if fillsize > 0x00000001
            newelem = element
        else
            newelem = ifelse(is_ones_runs(element), WAH_LITERAL_ONES, WAH_LITERAL_ZEROS)
        end
        push!(vec, newelem)
    end
end

@inline function append_run_slow!(vec::Vector{WAHElement}, element::WAHElement)
    tail = vec[endof(vec)]
    # If the tail and the element to append are runs with the same fill value.
    if matchingfills(element, tail)
        space_required = nruns(element)
        space_avail = nfree(tail)
        # If tail has room, simply up the runcount.
        if (space_avail >= space_required)
            vec[endof(vec)] += space_required
        else
            # If the tail has room, but not all room needed. Fill it, and add a
            # new element containing the remainder.
            vec[endof(vec)] += space_avail
            element -= space_avail
            # If the remainder is only one, thenm make the element a literal,
            # rather than a run.
            if nruns(element) == 1
                element = runval(element) == 0x00000001 ? 0x7FFFFFFF : 0x00000000
            end
            push!(vec, element)
        end
    # If the tail matches the fillvalue, but is a literal.
    elseif tail == WAH_LITERAL_ONES && (runval(element) == 0x00000001)
        if hasroom(element)
            vec[endof(vec)] = element + 1
        else
            vec[endof(vec)] = element
            push!(vec, WAH_LITERAL_ONES)
        end
    elseif tail == WAH_LITERAL_ZEROS && (runval(element) == 0x00000000)
        if hasroom(element)
            vec[endof(vec)] = element + 1
        else
            vec[endof(vec)] = element
            push!(vec, WAH_LITERAL_ZEROS)
        end
    # Final scenario, the tail does not match. The tail may be a literal that
    # is not all 0 or 1, or it may be a fill value not matching
    else
        push!(x, newelem)
    end
end
