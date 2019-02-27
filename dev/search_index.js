var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#WAHVectors.jl-Documentation-1",
    "page": "Home",
    "title": "WAHVectors.jl Documentation",
    "category": "section",
    "text": "Test"
},

{
    "location": "man/api_elements/#",
    "page": "WAHElements",
    "title": "WAHElements",
    "category": "page",
    "text": ""
},

{
    "location": "man/api_elements/#WAHVectors.isruns-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.isruns",
    "category": "method",
    "text": "isruns(x::WAHElement)\n\nReturn true if the element of the WAH compressed bit array x represents a compressed run of words. Otherwise return false.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.isliteral-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.isliteral",
    "category": "method",
    "text": "isliteral(x::WAHElement)\n\nReturn true if the element of the WAH compressed bit array x represents a literal word rather than a compressed run of words, in which case this function will return false.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.is_zeros_runs-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.is_zeros_runs",
    "category": "method",
    "text": "is_zeros_runs(x::WAHElement)\n\nReturn true if the WAH Element represents a compressed run of all zero words.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.is_ones_runs-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.is_ones_runs",
    "category": "method",
    "text": "is_ones_runs(x::WAHElement)\n\nReturn true if the WAH Element represents a compressed run of all one words.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.nwords-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.nwords",
    "category": "method",
    "text": "nwords(x::WAHElement)\n\nGet the number of words represented by this single WAHElement.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.runval-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.runval",
    "category": "method",
    "text": "runval(x::WAHElement)\n\nGet the runvalue of a compressed WAHElement.\n\nwarning: Warning\nOutput will not make sense if you use it on a WAH element that represents a literal word (i.e. isliteral(x) returns true) rather than a number of compressed words.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.nruns-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.nruns",
    "category": "method",
    "text": "nruns(x::WAHElement)\n\nGet the number of words represented by this single WAHElement, assuming it is a compressed element.\n\nwarning: Warning\nOutput will not make sense if you use it on a WAH element that represents a literal word (i.e. isliteral(x) returns true) rather than a number of compressed words.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.nfree-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.nfree",
    "category": "method",
    "text": "nfree(x::WAHElement)\n\nReturn how many more words this WAHElement can compress into it.\n\nwarning: Warning\nOutput will not make sense if you use it on a WAH element that represents a literal word (i.e. isliteral(x) returns true) rather than a number of compressed words.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#WAHVectors.isfull-Tuple{WAHVectors.WAHElement}",
    "page": "WAHElements",
    "title": "WAHVectors.isfull",
    "category": "method",
    "text": "isfull(x::WAHElement)\n\nCheck whether this WAHElement contains as many words as it can.\n\nwarning: Warning\nOutput will not make sense if you use it on a WAH element that represents a literal word (i.e. isliteral(x) returns true) rather than a number of compressed words.\n\n\n\n\n\n"
},

{
    "location": "man/api_elements/#API:-WAHElements-1",
    "page": "WAHElements",
    "title": "API: WAHElements",
    "category": "section",
    "text": "WAHVectors.isruns(x::WAHVectors.WAHElement)\nWAHVectors.isliteral(x::WAHVectors.WAHElement)\nWAHVectors.is_zeros_runs(x::WAHVectors.WAHElement)\nWAHVectors.is_ones_runs(x::WAHVectors.WAHElement)\nWAHVectors.nwords(x::WAHVectors.WAHElement)\nWAHVectors.runval(x::WAHVectors.WAHElement)\nWAHVectors.nruns(x::WAHVectors.WAHElement)\nWAHVectors.nfree(x::WAHVectors.WAHElement)\nWAHVectors.isfull(x::WAHVectors.WAHElement)"
},

]}
