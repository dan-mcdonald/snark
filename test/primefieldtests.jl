# N non-prime
@test_throws Exception PrimeFieldInt{255}(1).val == 1

# N is prime
@test PrimeFieldInt{251}(1).val == 1
