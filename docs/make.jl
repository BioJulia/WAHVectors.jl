using Documenter, WAHVectors

makedocs(
    format = :html,
    modules = [WAHVectors],
    sitename = WAHVectors,
    doctest = false,
    strict = false,
    pages = [
        "Home" => "index.md",
        "API" => [
            "WAHElements" => "api_elements.md"
        ]
    ],
    authors = "Ben J. Ward"
)
deploydocs(repo = "github.com/BioJulia/WAHVectors.jl.git")
