polyvariateCoeffs = [1 2 3; 4 5 6; 7 8 9;;; 10 11 12; 13 14 15; 16 17 18;;; 19 20 21; 22 23 24; 25 26 27]

@test SumCheckProtocol(PolyvariatePolynomial(polyvariateCoeffs))

@test SumCheckProtocol(PolyvariatePolynomial(map(PrimeFieldInt{251} ∘ UInt8, polyvariateCoeffs)))
