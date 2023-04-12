using Test
import TypedPolynomials as TP
import snark

@TP.polyvar x[1:3]

@test snark.varidx(x[1]) == 1
@test snark.varidx(x[3]) == 3

@test snark.nvars(x[1]+1) == 1
@test snark.nvars(x[1]^3+2x[2]^2*x[1]^2+3*x[1]*x[3]^2-5) == 3

@test snark.degree(x[1]+1) == 1
@test snark.degree(x[1]^3) == 3
@test snark.degree(7x[2]^2) == 2
@test snark.degree(7x[2]^2+x[1]^3) == 3

@test snark.degree(7x[2]^2+x[1]^3, 1) == 3
@test snark.degree(7x[2]^2+x[1]^3, 2) == 2

@test snark.eval(3x[1]^3-5, 2) == 24-5

@test snark.SumCheckProtocol(x[1]^3+2x[2]^2*x[1]^2+3*x[1]*x[3]^2-5)
