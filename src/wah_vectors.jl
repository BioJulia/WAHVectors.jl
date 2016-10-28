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
    decode!(xcursor)
    decode!(ycursor)
    push!(result.data, xc & yc)
    while (xc.word_i <= xc.len) && (yc.word_i <= yc.len)
        check_to_move!(xc)
        check_to_move!(yc)
        append!(result, xc & yc)
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
