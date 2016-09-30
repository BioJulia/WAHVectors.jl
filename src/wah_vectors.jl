# WAH Vectors
# ===========
#
# Construction of a WAHVectors.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md


function Base.push!(a::Vector{WAHElement}, value::UInt32)
    if length(a) == 0
        # First element gets added as a literal value.
        push!(a, convert(WAHElement, value))
    elseif value == 0x00000000
        a_tail = reinterpret(UInt32, a[endof(a)])
        if a_tail == 0x00000000
            a[endof(a)] = 0x80000002
        elseif (a_tail >= 0x80000000) && (a_tail < 0xC0000000)
            a[endof(a)] += UInt32(1)
        else
            push!(a, convert(WAHElement, value))
        end
    elseif value == 0x7FFFFFFF
        a_tail = reinterpret(UInt32, a[endof(a)])
        if a_tail == 0x7FFFFFFF
            a[endof(a)] = 0xC0000002
        elseif (a_tail >= 0xC0000000)
            a[endof(a)] += UInt32(1)
        else
            push!(a, convert(WAHElement, value))
        end
    else
        push!(a, convert(WAHElement, value))
    end
end


function Vector{WAHElements}(x::Vector{UInt32})
    n_cmp = (x[1] & UInt32(1)) << 30
    t_cmp = x[1] >> 1
    wah = Vector{WAHElement}(0)
    push!(wah, t_cmp)
    @inbounds for i in 2:endof(x)
        t_cmp = x[i] >> 1
        t_cmp = t_cmp | n_cmp
        push!(wah, t_cmp)
        n_cmp = (x[i] & UInt32(1)) << 30
    end
    return wah
end
