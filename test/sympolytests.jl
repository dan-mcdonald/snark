using Test
using Symbolics
using snark

@variables x[1:3]

@test snark.varidx(x[1]) == 1
@test snark.varidx(x[3]) == 3

@test degree(SymPoly(x[1], (x[1],))) == 1
@test degree(SymPoly(x[1]^3, (x[1],))) == 3
@test degree(SymPoly(7x[2]^2, (x[2],))) == 2
@test degree(SymPoly(7x[2]^2+x[1]^3, (x[1], x[2]))) == 3

@test degree(SymPoly(7x[2]^2+x[1]^3, (x[1], x[2])), 1) == 3
@test degree(SymPoly(7x[2]^2+x[1]^3, (x[1], x[2])), 2) == 2

@test snark.eval(SymPoly(3x[1]^3, 3), 2) == 24

g = x[1]^3+2x[2]^2*x[1]^2+3*x[1]*x[3]^2-5
@test SumCheckProtocol(SymPoly(g, (x[1], x[2], x[3])))
