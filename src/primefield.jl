using Primes
using Random

export PrimeFieldInt
struct PrimeFieldInt{T,N}
    val::T
    function PrimeFieldInt{N}(val::T) where {T,N}
        if typemax(T) < N-1
            error("type can't represent over the field range")
        elseif !Primes.isprime(N)
            error("N=$N not prime")
        end
        new{T,N}(mod(val,N))
    end
end

Base.zero(::Type{PrimeFieldInt{T,N}}) where {T,N} = PrimeFieldInt{N}(zero(T))
Base.one(::Type{PrimeFieldInt{T,N}}) where {T,N} = PrimeFieldInt{N}(one(T))

Base.iszero(x::PrimeFieldInt) = iszero(x.val)

# TODO fix bias
Random.rand(rng::AbstractRNG, ::Random.SamplerType{PrimeFieldInt{T,N}}) where {T,N} = PrimeFieldInt{N}(rand(rng, T))

function Base.:^(base::PrimeFieldInt{T,N}, exp::Int)::PrimeFieldInt{T,N} where {T,N}
    if exp < 0
        error("negative exponents not supported")
    end
    PrimeFieldInt{N}(T(mod(BigInt(base.val)^exp, N)))
end

#Base.:*(a::Int, b::PrimeFieldInt) = *(PrimeFieldInt(a, b.p), b)

# TODO handle overflow
Base.:*(a::PrimeFieldInt{T,N}, b::PrimeFieldInt{T,N}) where {T,N} = PrimeFieldInt{N}(T(mod(BigInt(a.val)*BigInt(b.val), N)))

Base.:*(a::PrimeFieldInt)::PrimeFieldInt{T,N} = a

# TODO handle overflow
Base.:+(a::PrimeFieldInt{T,N}, b::PrimeFieldInt{T,N}) where {T,N} = PrimeFieldInt{N}(T(mod(BigInt(a.val)+BigInt(b.val), N)))

Base.:-(x::PrimeFieldInt{T,N}) where {T,N} = PrimeFieldInt{N}(-x.val)
