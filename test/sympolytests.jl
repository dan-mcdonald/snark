using Test
import TypedPolynomials as TP
import snark

@TP.polyvar x[1:3]

@test snark.varidx(x[1]) == 1
@test snark.varidx(x[3]) == 3

@test snark.nvars(x[1]+1) == 1
@test snark.nvars(x[1]^3+2x[2]^2*x[1]^2+3*x[1]*x[3]^2-5) == 3

@test snark.domain(x[1]+1) == Int
@test snark.domain(0x01*x[1]^3 + 0x02*x[2]^2*x[1]^2 + 0x03*x[1]*x[3]^2-0x05) == UInt8

@test snark.degree(x[1]+1) == 1
@test snark.degree(x[1]^3) == 3
@test snark.degree(7x[2]^2) == 2
@test snark.degree(7x[2]^2+x[1]^3) == 3

@test snark.degree(7x[2]^2+x[1]^3, 1) == 3
@test snark.degree(7x[2]^2+x[1]^3, 2) == 2

@test snark.eval(3x[1]^3-5, 2) == 24-5
@test snark.eval(3x[3]^3-5, 2) == 24-5


@test snark.SumCheckProtocol(x[1]^3+2x[2]^2*x[1]^2+3*x[1]*x[3]^2-5)

@test snark.partialEval(0x01*x[1]^3 + 0x02*x[2]^2*x[1]^2 + 0x03*x[1]*x[3]^2-0x05, (0x11, 0x00, 0x00), 2) == 66*x[2]^2 + 44

@test snark.SumCheck(0x01*x[1]^3 + 0x02*x[2]^2*x[1]^2 + 0x03*x[1]*x[3]^2-0x05) <= 0xff

@test snark.SumCheckProtocol(0x01*x[1]^3 + 0x02*x[2]^2*x[1]^2 + 0x03*x[1]*x[3]^2-0x05)

p251 = n -> PrimeFieldInt{251}(n)

@test snark.SumCheckProtocol(p251(1)*x[1]^3 + p251(2)*x[2]^2*x[1]^2 + p251(3)*x[1]*x[3]^2-p251(5))
