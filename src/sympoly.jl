import MultivariatePolynomials as MP
import TypedPolynomials as TP

export nvars, degree

function nvars(sp::TP.Polynomial)
    MP.nvariables(sp)
end

function value_type(p::TP.Polynomial{T, V1, V2}) where {T,V1,V2}
    T
end

function eval(sp::TP.Polynomial, xs::Tuple{Vararg{T,N}}) where {T,N}
    partialEval(sp, xs, -1)
end

# special form for univariate polynomial
function eval(sp::TP.Polynomial, v)
    eval(sp, (v,))
end

function partialEval(sp::TP.Polynomial, xs::Tuple{Vararg{T,N}}, freeIndex::Int) where {T,N}
    nonZeroDegree = v -> MP.maxdegree(sp, v) > 0
    polyVars = MP.variables(sp) |>
        collect |>
        vs -> filter(nonZeroDegree, vs) |>
        vs -> sort(vs; by=varidx)
    length(xs) == length(polyVars) || error("partialEval mismatch between polynomial $sp with vars $polyVars and provided values $xs")
    subVars = [polyVars[i] => xs[i] for i = 1:N if i != freeIndex]
    TP.subs(sp, subVars...)
end

function varidx(v::T) where {T <: MP.AbstractVariable}
    MP.name_base_indices(v)[2][1]
end

function degree(sp::Union{TP.Polynomial, TP.Monomial, TP.Term})
    MP.maxdegree(sp)
end

function degree(sp::TP.Polynomial, j)
    v = filter(v -> [j] == MP.name_base_indices(v)[2], MP.variables(sp))[1]
    MP.maxdegree(sp, v)
end

function domain(::TP.Polynomial)
    Int
end
