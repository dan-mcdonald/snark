using Test
using Symbolics
using snark

@variables x[1:3]

@test snark.varidx(x[1]) == 1
@test snark.varidx(x[3]) == 3

@test degree(SymPoly(x[1])) == 1
@test degree(SymPoly(x[1]^3)) == 3
@test degree(SymPoly(7x[2]^2)) == 2
@test degree(SymPoly(7x[2]^2+x[1]^3)) == 3

@test degree(SymPoly(7x[2]^2+x[1]^3), 1) == 3
@test degree(SymPoly(7x[2]^2+x[1]^3), 2) == 2

@test snark.eval(SymPoly(3x[1]^3), 2) == 24

@test SumCheckProtocol(SymPoly(x[1]^3+2x[2]^2*x[1]^2+3*x[1]*x[3]^2-5))
