using Documenter, PolynomialRings

makedocs(
    modules  = [PolynomialRings],
    repo     = "https://github.com/tkluck/PolynomialRings.jl.git",
    doctest  = true,
    sitename = "PolynomialRings.jl",
    authors  = "Timo Kluck",
    pages    = [
        # keep in sync with index.md
        "Home"                => "index.md",
        "Getting Started"     => "getting-started.md",
        "Design Goals"        => "design-goals.md",
        "Other packages"      => "other-packages.md",
        "Types and Functions" => "functions.md",
        "Reference Index"     => "reference.md",
    ],
    format = Documenter.HTML(
        canonical = "http://tkluck.github.io/PolynomialRings.jl/stable/",
    ),
)
deploydocs(
    repo   = "github.com/tkluck/PolynomialRings.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
)
