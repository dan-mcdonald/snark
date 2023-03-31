@test arithmetize(:(!x[1])) == :(1 - x[1])

@test arithmetize(:(x[2]&x[3])) == :(x[2] * x[3])

@test arithmetize(:(x[3]|x[4])) == :(x[3] + x[4] - x[3] * x[4])

@test arithmetize(:(!x[1] | !x[3])) == :((1-x[1]) + (1-x[3]) - (1-x[1]) * (1-x[3]))

@test arithmetize(:((!x[1] & x[2]) & (x[3] | x[4]))) == :(((1 - x[1]) * x[2]) * ((x[3] + x[4]) - (x[3] * x[4])))
