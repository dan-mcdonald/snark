import MultivariatePolynomials as MP
import TypedPolynomials as TP

export nvars, degree

function nvars(sp::TP.Polynomial)
    MP.nvariables(sp)
end

function eval(sp::TP.Polynomial{T,TT,VT}, xs::Tuple{Vararg{T,N}})::T where {T,N,TT,VT}
    partialEval(sp, xs, -1)
end

# special form for univariate polynomial
function eval(sp::TP.Polynomial{CoeffType,TermType,VarType}, v)::CoeffType where {CoeffType,TermType,VarType}
    freeVar = only(MP.variables(sp))
    sp(freeVar => v)
end

function partialEval(sp::TP.Polynomial, xs::Tuple{Vararg{T,N}}, freeIndex::Int) where {T,N}
    zeroDegree = v -> MP.maxdegree(sp, v) == 0
    isFreeVar = v -> varidx(v) == freeIndex
    subVars = MP.variables(sp) |>
        vs -> filter(v -> !zeroDegree(v) && !isFreeVar(v), vs) |>
        vs -> map(v -> v => xs[varidx(v)], vs)
    TP.subs(sp, subVars...)
end

function varidx(v::MP.AbstractVariable)
    MP.name_base_indices(v)[2][1]
end

function degree(sp::Union{TP.Polynomial, TP.Monomial, TP.Term})
    MP.maxdegree(sp)
end

function degree(sp::TP.Polynomial, j)
    v = filter(v -> [j] == MP.name_base_indices(v)[2], MP.variables(sp))[1]
    MP.maxdegree(sp, v)
end

function domain(::TP.Polynomial{CoeffType,TermType,VarType}) where {CoeffType,TermType,VarType}
    CoeffType
end
