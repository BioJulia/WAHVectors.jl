# WAHVectors
# ==========
#
# Bit Vectors compressed using a Word Aligned Hybrid method.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

module WAHVectors

include("wah_elements.jl")
include("vector_wahelement.jl")
include("wah_vectors.jl")
include("wah_cursor.jl")

export WAHElement,
    WAH_LITERAL_ZEROS,
    WAH_LITERAL_ONES,
    WAH_FULL_ZEROS,
    WAH_FULL_ONES,
    WAH_MAX_NWORDS,
    isruns,
    isliteral,
    is_zeros_runs,
    is_ones_runs,
    nwords,
    runval,
    nruns,
    nfree,
    isfull




end
