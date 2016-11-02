using Documenter, WAHVectors

makedocs()
deploydocs(
    deps = Deps.pip("mkdocs", "pygments", "mkdocs-biojulia"),
    repo = "github.com/BioJulia/WAHVectors.jl.git",
    julia = "0.5",
    osname = "linux"
)
