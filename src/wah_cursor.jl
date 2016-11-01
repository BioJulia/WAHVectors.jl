# WAH Vector Cursors
# ==================
#
# A type that acts as a cursor through a WAHVector during some looping
# operations.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

type WAHCursor
    wahvec::WAHVector
    len::Int
    word_i::Int
    fill::UInt32
    isfill::Bool
    fillbit::UInt32
    nwords::UInt32

    function WAHCursor(vec::WAHVector)
        return new(x, length(x.data), 1, 0x00000000, false, 0x00000000, 0x00000000)
    end
end

@inline function move!(x::WAHCursor)
    currentWord = x.wahvec.data[x.word_i]
    if isruns(currentWord)
        isones = is_ones_runs(currentWord)
        x.fill = ifelse(isones, 0x7FFFFFFF, 0x00000000)
        x.nwords = nwords(currentWord)
        x.isfill = true
        x.fillbit = ifelse(isones, 0x00000001, 0x00000000)
    else
        x.nwords = 0x00000001
        x.isfill = false
        x.fill = x.wahvec.data[x.word_i]
    end
end

@inline function check_to_move!(x::WAHCursor)
    if x.nwords == 0x00000000
        x.word_i += 1
        if x.word_i < x.len
            move!(x)
        end
    end
end

@inline function Base.:&(x::WAHCursor, y::WAHCursor)
    if x.isfill
        if y.isfill
            num_words = min(x.nwords, y.nwords)
            x.nwords -= num_words
            y.nwords -= num_words
            #answer = WAHElement(x.fillbit & y.fillbit, num_words)
            return WAHElement(x.fillbit & y.fillbit, num_words)
        else
            #answer = WAHElement(x.fill & y.wahvec.data[y.word_i])
            #answer = WAHElement(x.fill & y.fill)
            x.nwords -= 0x00000001
            y.nwords = 0x00000000
        end
    elseif y.isfill
        #answer = WAHElement(x.wahvec[x.word_i] & y.fill)
        #answer = WAHElement(x.fill & y.fill)
        y.nwords -= 0x00000001
        x.nwords = 0x00000000
    else
        #answer = WAHElement(x.wahvec[x.word_i] & y.wahvec[y.word_i])
        #answer = WAHElement(x.fill & y.fill)
        x.nwords = 0x00000000
        y.nwords = 0x00000000
    end
    #return answer
    return WAHElement(x.fill & y.fill)
end

@inline function _compute_and_vec(x::WAHCursor, y::WAHCursor)
    num_words = min(x.nwords, y.nwords)
    xyfill = x.isfill & y.isfill
    xfill = x.isfill & !y.isfill
    yfill = !x.isfill & x.isfill
    nofill = !x.isfill & y.isfill
    x.nwords -= ifelse(xyfill, num_words, 0)
    x.nwords -= ifelse(xfill, 1, 0)
    x.nwords = ifelse(yfill | nofill, 0, x.nwords)
    y.nwords -= ifelse(xyfill, num_words, 0)
    y.nwords -= ifelse(yfill, 1, 0)
    y.nwords = ifelse(xfill | nofill, 0, y.nwords)
    answer = ifelse(xyfill,
        WAHElement(x.fillbit & y.fillbit, num_words),
        WAHElement(x.fill & y.fill))
    return answer
end
