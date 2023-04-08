using Symbolics

export nvars, SymPoly, degree

struct SymPoly
    poly
    xs
end

function nvars(sp::SymPoly)
    length(sp.xs)
end

function eval(sp::SymPoly, xs::Tuple{Vararg{T,N}}) where {T,N}
    partialEval(sp, xs, -1).poly
end

function eval(sp::SymPoly, v)
    freeVars = Symbolics.get_variables(sp.poly)
    length(freeVars) == 1 || error("eval expected 1 free var but got: $freeVars")
    substitute(sp.poly, Dict(freeVars[1] => v))
end

function partialEval(sp::SymPoly, xs::Tuple{Vararg{T,N}}, freeIndex::Int) where {T,N}
    subVars = Dict(sp.xs[i] => xs[i] for i = 1:N if i != freeIndex)
    println("substituting values = ", subVars)
    newPoly = Symbolics.substitute(sp.poly, subVars)
    newXs = Symbolics.get_variables(newPoly)
    SymPoly(newPoly, newXs)
end

# TODO you know
Base.zero(::SymPoly) = 0
Base.one(::SymPoly) = 1

function Base.:+(a::SymPoly, b::SymPoly)
    sumPoly = a.poly + b.poly
    SymPoly(sumPoly, Symbolics.get_variables(sumPoly))
end

varidx(n::Num) = varidx(n.val)

function varidx(b)
    op = operation(b)
    op == getindex || error("varidx got unexpected operation: $op")
    args = arguments(b)
    length(args) == 2 || error("varidx got unexpected arguments: $args")
    args[2]
end

function degree(sp::SymPoly)
    degree(sp.poly.val, missing)
end

function degree(bs::SymbolicUtils.BasicSymbolic, j)
    # if istree(bs)
    degree(Val{operation(bs)}(), arguments(bs), j)
    # else
    #     0
    # end
end

function degree(_::Val{getindex}, args, j)
    1
end

function degree(_::Val{^}, args, j)
    ismissing(j) || varidx(args[1]) == j ? args[2] : 0
end

function degree(_::Val{*}, args, j)
    maximum(x -> degree(x, j), args)
end

function degree(_::Val{+}, args, j)
    maximum(x -> degree(x, j), args)
end

function degree(::Int, j)
    0
end

function degree(sp::SymPoly, j)
    degree(sp.poly.val, j)
end

domain(::SymPoly) = Int
