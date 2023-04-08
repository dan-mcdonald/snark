export PolyvariatePolynomial
struct PolyvariatePolynomial{T,N}
    coeffs::Array{T,N}
end

export domain
domain(::PolyvariatePolynomial{T,N}) where {T,N} = T

export nvars
function nvars(::PolyvariatePolynomial{T,N}) where {T,N}
    N
end

# degree of the j'th free variable
function degree(g::PolyvariatePolynomial, j)::Int
    size(g.coeffs, j)
end

function eval(g::PolyvariatePolynomial{T,N}, x::Tuple{Vararg{T,N}}) where {T,N}
    computeTerm(coeffIdx) = g.coeffs[coeffIdx] * mapreduce((x_i, powerIdx) -> x_i ^ (powerIdx - 1), *, x, coeffIdx.I)
    sum(computeTerm, CartesianIndices(g.coeffs))
end

struct UnivariatePolynomial{T}
    coeffs::Vector{T}
end

function degree(f::UnivariatePolynomial)::Int
    length(f.coeffs)
end

function Base.:+(a::UnivariatePolynomial{T}, b::UnivariatePolynomial{T}) where {T}
    UnivariatePolynomial(a.coeffs+b.coeffs)
end

function lagrangeExtension(fvals::Vector)
    
end

#fvec = [3, 4, 1, 2]

# println(lagrangeExtension(fvec))

#g(x) = 2x[1]^3 + x[1]*x[3] + x[2]*x[3]

function eval(f::UnivariatePolynomial{T}, x::T) where {T}
    mapreduce(*, +, f.coeffs, map(expo -> x ^ expo, 0:length(f.coeffs)-1))
end

struct UnivariatePolynomialTerm{T}
    coeff::T
    degree::Int
end

function simplifyTerm(idx::CartesianIndex, coeff::T, x, freeIndex::Int)::UnivariatePolynomialTerm{T} where {T}
    numVars = length(idx.I)
    boundVarIndices = filter(i -> i != freeIndex, 1:numVars)
    simplifiedCoeff = coeff * prod(i -> x[i]^(idx.I[i]-1), boundVarIndices)
    UnivariatePolynomialTerm(simplifiedCoeff, idx.I[freeIndex]-1)
end

function partialEval(f::PolyvariatePolynomial{T,N}, x::Tuple{Vararg{T,N}}, freeIndex::Int) where {T,N}
    simplifiedTerms = map(idx -> simplifyTerm(idx, f.coeffs[idx], x, freeIndex), CartesianIndices(f.coeffs))
    coeffs = foldl( 
        (acc, term) -> begin
            acc[term.degree+1] += term.coeff
            acc
        end,
        simplifiedTerms;
        init=zeros(T, maximum(flatten(axes(f.coeffs))))
    )
    UnivariatePolynomial(coeffs)
end

function simplifyTerms()
    maxDegree = max(flatten(axes(f.coeffs))...)
    univariateCoeffs = zeros(T, maxDegree)
    for term in simplifiedTerms
        univariateCoeffs[term.degree+1] += term.coeff
    end
    UnivariatePolynomial(univariateCoeffs)
end

Base.zero(_::PolyvariatePolynomial{T,N}) where {T,N} = zero(T)
Base.one(_::PolyvariatePolynomial{T,N}) where {T,N} = one(T)
