# WAHVectors
# ==========
#
# Bit Vectors compressed using a Word Aligned Hybrid method.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/WAHVectors.jl/blob/master/LICENSE.md

module WAHVectors

include("wah_elements.jl")
include("wah_vectors.jl")

export WAHElement,
    build_wah_array



end
