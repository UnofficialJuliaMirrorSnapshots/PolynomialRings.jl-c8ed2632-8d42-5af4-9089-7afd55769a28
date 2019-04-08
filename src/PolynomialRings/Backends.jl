module Backends

module Gröbner
    abstract type Backend end
    struct NamedBackend{Name} <: Backend end
    const GWV = NamedBackend{:gwv}
    const F5C = NamedBackend{:f5c}
    const Arri = NamedBackend{:arri}
    const M4GB = NamedBackend{:m4gb}
    _default = M4GB()
    cur_default = _default
    set_default()  = (global cur_default; cur_default=_default)
    set_default(x) = (global cur_default; cur_default=x)

    using PolynomialRings
    import PolynomialRings: gröbner_basis, gröbner_transformation, lift, monomialorder

    # fallback in case a backend only provides a subset of these
    gröbner_basis(b::Backend, args...; kwds...)         = gröbner_transformation(b, args...; kwds...)[1]
    gröbner_transformation(::Backend, args...; kwds...) = gröbner_transformation(GWV(), args...; kwds...)
    lift(b::Backend, G, y; kwds...)                     = lift(b, G, (y,); kwds...)[1]
    function lift(b::Backend, G, y::Tuple; kwds...)
        gr, tr = gröbner_transformation(b, G; kwds...)
        map(y) do y_i
            f, y_red = divrem(y_i, gr)
            iszero(y_red) ? f * tr : nothing
        end
    end

    # fallback in case a monomial order is not passed explicitly: choose it from G
    gröbner_basis(b::Backend, G::AbstractVector, args...; kwds...) = gröbner_basis(b, monomialorder(eltype(G)), G, args...; kwds...)
    gröbner_transformation(b::Backend, G::AbstractVector, args...; kwds...) = gröbner_transformation(b, monomialorder(eltype(G)), G, args...; kwds...)
    """
        basis, transformation = gröbner_transformation(polynomials)

    Return a Gröbner basis for the ideal generated by `polynomials`, together with a
    `transformation` that proves that each element in `basis` is in that ideal (i.e.
    `basis == transformation * polynomials`).

    This is computed using the GWV algorithm with a few standard
    optmizations; see [`PolynomialRings.GröbnerGWV.gwv`](@ref) for details.
    """
    function gröbner_transformation(G::AbstractVector, args...; kwds...)
         kwds = copy(kwds)
         alg = pop!(kwds, :alg, cur_default)
         if alg isa Symbol
             alg = NamedBackend{alg}()
         end
         gröbner_transformation(alg, G, args...; kwds...)
     end

    """
        basis = gröbner_basis(polynomials)

    Return a Gröbner basis for the ideal generated by `polynomials`.

    This is computed using the GWV algorithm; see
    [`PolynomialRings.GröbnerGWV.gwv`](@ref) for details.
    """
    function gröbner_basis(G::AbstractVector, args...; kwds...)
         kwds = copy(kwds)
         alg = pop!(kwds, :alg, cur_default)
         if alg isa Symbol
             alg = NamedBackend{alg}()
         end
         gröbner_basis(alg, G, args...; kwds...)
     end

    """
        factors = lift(polynomials, y)

    Return a row vector of `factors` such that `factors * polynomials` is equal
    to `y`, or `nothing` if `y` is not in the ideal generated by `polynomials`.

    This is computed using `gröbner_transformation`; see there for more information.

    Note: if you need to compute many lifts for the same set of
    `polynomials`, it is beneficial to use `gröbner_transformation` yourself as
    it avoids re-doing the most computationally intensive part.
    """
    function lift(G::AbstractVector, y, args...; kwds...)
         kwds = copy(kwds)
         alg = pop!(kwds, :alg, cur_default)
         if alg isa Symbol
             alg = NamedBackend{alg}()
         end
         lift(alg, G, y, args...; kwds...)
     end

end
end