export arithmetize

function arithmetize(e::Expr)
    arithmetize_expr(Val{e.head}(), e.args)
end

function arithmetize_expr(_::Val{:call}, args)
    arithmetize_call(Val{args[1]}(), args[2:length(args)]...)
end

function arithmetize_call(_::Val{:!}, x)
    x = arithmetize(x)
    :(1 - $x)
end

function arithmetize_call(_::Val{:&}, x, y)
    x = arithmetize(x)
    y = arithmetize(y)
    :($x * $y)
end

function arithmetize_call(_::Val{:|}, x, y)
    x = arithmetize(x)
    y = arithmetize(y)
    :($x + $y - $x * $y)
end

function arithmetize_expr(_::Val{:ref}, args)
    arithmetize_ref(args...)
end

function arithmetize_ref(sym::Symbol, idx::Int)
    Expr(:ref, sym, idx)
end
