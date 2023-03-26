using .Iterators

function SumCheck(g::PolyvariatePolynomial{T,N}) where {T,N} 
    sum((x) -> eval(g, x), product(repeated((zero(T), one(T)), N)...))
end

function SumCheckHonestProver(p2v::Channel, v2p::Channel, g::PolyvariatePolynomial{T,N}) where {T,N}
    c1 = SumCheck(g)
    println("c1 computed as ", c1)
    put!(p2v, c1)
    r = ()
    nvars = ndims(g)
    for j in 1:nvars
        println("prover starting round ", j)
        concatVars = free -> (r..., zero(T), free...)
        partialEvalg = vars -> partialEval(g, vars, j)
        allCombosFreeVars = product(repeated((zero(T), one(T)), nvars - j)...)
        g_j = UnivariatePolynomial(sum(partialEvalg ∘ concatVars, allCombosFreeVars))
        println("prover sending g_j = ", g_j)
        put!(p2v, g_j)
        r_j = take!(v2p)
        println("prover got r_j = ", r_j)
        r = (r..., r_j)
    end
end

function SumCheckVerifier(p2v::Channel, v2p::Channel, g::PolyvariatePolynomial{T,N}) where {T,N}
    c1 = take!(p2v)
    println("verifier got asserted c1 = ", c1)
    r = ()
    for j in 1:N
        println("verifier starting round ", j)
        g_j = take!(p2v)
        println("verifier got g_j = ", g_j)
        if degree(g_j) > degree(g, j)
            println("verifier detects invalid degree")
            return false
        end
        if eval(g_j, zero(T)) + eval(g_j, one(T)) != c1
            println("verifier sum does not equal expected value")
            return false
        end
        println("verifier tests pass for g_j")
        r_j = rand(T)
        r = (r..., r_j)
        println("verifier sending generated r_j = ", r_j)
        put!(v2p, r_j)
        c1 = eval(g_j, r_j)
        println("verifier calculated new expected c1 = ", c1)
    end
    return true
end

export SumCheckProtocol
function SumCheckProtocol(g::PolyvariatePolynomial)
    p2v = Channel()
    v2p = Channel()
    pTask = @async SumCheckHonestProver(p2v, v2p, g)
    bind(p2v, pTask)
    vTask = @async SumCheckVerifier(p2v, v2p, g)
    bind(v2p, vTask)
    vResult = fetch(vTask)
    println("verifier task ended with result = ", vResult)
    wait(pTask)
    println("prover task ended")
    return vResult
end
