using .Iterators

function SumCheck(g)
    valType = domain(g)
    mapreduce((x) -> eval(g, x), +, product(repeated((zero(valType), one(valType)), nvars(g))...))
end

function allCombosFreeVars(g, j)
    valType = domain(g)
    product(repeated((zero(valType), one(valType)), nvars(g) - j)...)
end

function SumCheckHonestProver(p2v::Channel, v2p::Channel, g)
    c1 = SumCheck(g)
    println("c1 computed as ", c1)
    put!(p2v, c1)
    r = ()
    numvars = nvars(g)
    valType = domain(g)
    for j in 1:numvars
        println("prover starting round ", j)
        concatVars = free -> (r..., zero(valType), free...)
        partialEvalg = vars -> partialEval(g, vars, j)
        g_j = sum(partialEvalg ∘ concatVars, allCombosFreeVars(g, j))
        println("prover sending g_j = ", g_j)
        put!(p2v, g_j)
        r_j = take!(v2p)
        println("prover got r_j = ", r_j)
        r = (r..., r_j)
    end
end

function SumCheckVerifier(p2v::Channel, v2p::Channel, g)
    valType = domain(g)
    c1 = take!(p2v)
    println("verifier got asserted c1 = ", c1)
    r = ()
    for j in 1:nvars(g)
        println("verifier starting round ", j)
        g_j = take!(p2v)
        println("verifier got g_j = $g_j (type=$(typeof(g_j)))")
        degree(g_j) <= degree(g, j) || error("verifier detects invalid degree")
        g_j_0 = eval(g_j, zero(valType))
        g_j_1 = eval(g_j, one(valType))
        g_j_0 + g_j_1 == c1 || error("verifier g_j(0) ($g_j_0) + g_j(1) ($g_j_1) does not equal expected value c1 = $c1")
        println("verifier tests pass for g_j")
        r_j = rand(domain(g))
        r = (r..., r_j)
        println("verifier sending generated r_j = ", r_j)
        put!(v2p, r_j)
        c1 = eval(g_j, r_j)
        println("verifier calculated new expected c1=$c1 (type=$(typeof(c1)))")
    end
    return true
end

export SumCheckProtocol
function SumCheckProtocol(g)
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
