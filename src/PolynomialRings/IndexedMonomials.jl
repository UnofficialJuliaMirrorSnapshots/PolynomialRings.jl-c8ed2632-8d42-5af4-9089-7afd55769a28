module IndexedMonomials

import Base: *, ==, //, +, -
import Base: iszero, zero
import Base: hash, convert, exponent, iterate
import Base: lcm

import ProgressMeter: @showprogress

import ..Monomials: AbstractMonomial, _construct, num_variables, nzindices, maybe_div
import ..MonomialOrderings: MonomialOrder, NamedMonomialOrder, NumberedMonomialOrder
import ..NamingSchemes: NamingScheme
import PolynomialRings: monomialtype, exptype, basering, monomialorder, tail, divides, mutuallyprime

struct ByIndex end
"""
    IndexedMonomial{Order <: MonomialOrder, I <: Integer} <: AbstractMonomial{Order}

Represent a monomial by its well-ordered index according to `Order`.
"""
struct IndexedMonomial{Order <: MonomialOrder, I <: Integer} <: AbstractMonomial{Order}
    ix::I
    IndexedMonomial{Order, I}(::ByIndex, ix::I) where {Order, I} = new(ix)
end

monomialorder(::Type{IndexedMonomial{Order, I}}) where {Order, I} = Order()
exptype(::Type{IndexedMonomial{Order, I}}) where {Order, I} = I

densetype(::Type{IndexedMonomial{Order, I}}) where {Order, I} = monomialtype(Order())

(::Type{M})(m::M) where M <: IndexedMonomial = M(ByIndex(), m.ix)
convert(::Type{M}, m::M) where M <: IndexedMonomial = m

==(a::M, b::M) where M <: IndexedMonomial = a.ix == b.ix
hash(m::IndexedMonomial, h::UInt) = hash(m.ix, h)

function nzindices(m::IndexedMonomial)
    N = densetype(typeof(m))
    nzindices(convert(N, m))
end

function exponent(m::IndexedMonomial, ix)
    N = densetype(typeof(m))
    exponent(convert(N, m), ix)
end

Base.lt(::Order, a::M, b::M) where M <: IndexedMonomial{Order} where Order <: MonomialOrder{:degrevlex} = a.ix < b.ix

function _construct(::Type{M}, f, nz) where M <: IndexedMonomial
    N = densetype(M)
    convert(M, _construct(N, f, nz))
end

function *(a::M, b::M) where M <: IndexedMonomial
    N = densetype(M)
    res = convert(N, a) * convert(N, b)
    return convert(M, res)
end

_convertres(M, res) = convert(M, res)
_convertres(M, res::Nothing) = nothing
function maybe_div(a::M, b::M) where M <: IndexedMonomial
    N = densetype(M)
    res = maybe_div(convert(N, a), convert(N, b))
    return _convertres(M, res)
end

function lcm(a::M, b::M) where M <: IndexedMonomial
    N = densetype(M)
    res = lcm(convert(N, a), convert(N, b))
    return _convertres(M, res)
end

function divides(a::M, b::M) where M <: IndexedMonomial
    N = densetype(M)
    return divides(convert(N, a), convert(N, b))
end

function mutuallyprime(a::M, b::M) where M <: IndexedMonomial
    N = densetype(M)
    return mutuallyprime(convert(N, a), convert(N, b))
end

struct MonomialSet
    a::BitArray{1}
    MonomialSet() = new(BitArray{1}())
end

function Base.push!(s::MonomialSet, m::IndexedMonomial)
    length(s.a) <= m.ix && resize!(s.a, m.ix)
    s.a[m.ix] = true
end

Base.in(m::IndexedMonomial, s::MonomialSet) = length(s.a) >= m.ix && s.a[m.ix]


end
