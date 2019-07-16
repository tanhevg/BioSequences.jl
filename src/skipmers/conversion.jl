# Conversion & Construction
# -------------------------

# Create a Mer from a sequence whose elements are convertible to a nucleotide.
function (::Type{T})(seq) where {T<:AbstractMer}
    seqlen = length(seq)
    if seqlen != K(T)
        throw(ArgumentError("seq does not contain the correct number of nucleotides ($seqlen ≠ $K)"))
    end
    if seqlen > capacity(T)
        throw(ArgumentError("Cannot build a mer longer than $(capacity(T))bp long"))
    end

    x = zero(encoded_data_type(T))
    for c in seq
        nt = convert(eltype(T), c)
        if isambiguous(nt)
            throw(ArgumentError("cannot create a mer with ambiguous nucleotides"))
        elseif isgap(nt)
            throw(ArgumentError("cannot create a mer with gaps"))
        end
        x = (x << 2) | encoded_data_type(T)(twobitnucs[reinterpret(UInt8, nt) + 0x01])
    end

    return T(x)
end

(::Type{Mer{A}})(seq) where {A} = Mer{A,length(seq)}(seq)
(::Type{BigMer{A}})(seq) where {A} = BigMer{A,length(seq)}(seq)

function (::Type{T})(nts::Vararg{DNA,K}) where {K,T<:AbstractMer{DNAAlphabet{2},K}}
    return T(nts)
end

function (::Type{T})(nts::Vararg{RNA,K}) where {K,T<:AbstractMer{RNAAlphabet{2},K}}
    return T(nts)
end

LongSequence{A}(x::AbstractMer{A,K}) where {A<:DNAAlphabet,K} = LongSequence{A}([nt for nt in x])
LongSequence{A}(x::AbstractMer{A,K}) where {A<:RNAAlphabet,K} = LongSequence{A}([nt for nt in x])
LongSequence(x::AbstractMer{A,K}) where {A,K} = LongSequence{A}([nt for nt in x])

Base.convert(::Type{U}, x::AbstractMer) where {U<:Unsigned} = convert(U, encoded_data(x))

#=
# Create a Mer from a sequence whose elements are convertible to a nucleotide.
function (::Type{Skipmer{U, A, M, N, K}})(seq) where {U, A, M, N, K}
    checkskipmer(Skipmer{U, A, M, N, K})
    seqlen = length(seq)
    if seqlen != K
        throw(ArgumentError("seq does not contain the correct number of nucleotides ($seqlen ≠ $K)"))
    end

    x = zero(U)
    for c in seq
        nt = convert(eltype(Skipmer{U, A, M, N, K}), c)
        if isambiguous(nt)
            throw(ArgumentError("cannot create a skipmer with ambiguous nucleotides"))
        elseif isgap(nt)
            throw(ArgumentError("cannot create a skipmer with gaps"))
        end
        x = (x << 2) | U(twobitnucs[reinterpret(UInt8, nt) + 0x01])
    end

    return Skipmer{U, A, M, N, K}(x)
end
=#

#=
# Create a skipmer from a sequence whose elements are convertible to a nucleotide,
# without defining K.
function (::Type{Skipmer{U, A, M, N}})(seq) where {U, A, M, N}
    return Skipmer{U, A, M, N, length(seq)}(seq)
end
=#


# Construct a Skipmer from a series of nucleic acids.
#=
function Skipmer{U, DNAAlphabet{2}, M, N, K}(nts::Vararg{DNA,K}) where {U, M, N, K}
    return Skipmer{U, DNAAlphabet{2}, M, N, K}(nts)
end

function Skipmer{U, RNAAlphabet{2}, M, N, K}(nts::Vararg{RNA,K}) where {U, M, N, K}
    return Skipmer{U, RNAAlphabet{2}, M, N, K}(nts)
end

function Skipmer{U, DNAAlphabet{2}, M, N}(nts::Vararg{DNA,K}) where {U, M, N, K}
    return Skipmer{U, DNAAlphabet{2}, M, N, K}(nts)
end

function Skipmer{U, RNAAlphabet{2}, M, N}(nts::Vararg{RNA,K}) where {U, M, N, K}
    return Skipmer{U, RNAAlphabet{2}, M, N, K}(nts)
end
=#
# Construct Skipmers from integers...
#=
function Skipmer{UInt64, A, M, N, K}(i::Int64) where {A, M, N, K}
    return Skipmer{UInt64, A, M, N, K}(convert(UInt64, i))
end

function Skipmer{UInt128, A, M, N, K}(i::Int128) where {A, M, N, K}
    return Skipmer{UInt128, A, M, N, K}(convert(UInt128, i))
end

function Skipmer{UInt32, A, M, N, K}(i::Int32) where {A, M, N, K}
    return Skipmer{UInt32, A, M, N, K}(convert(UInt32, i))
end

function Skipmer{UInt16, A, M, N, K}(i::Int16) where {A, M, N, K}
    return Skipmer{UInt16, A, M, N, K}(convert(UInt16, i))
end

function Skipmer{UInt8, A, M, N, K}(i::Int8) where {A, M, N, K}
    return Skipmer{UInt8, A, M, N, K}(convert(UInt8, i))
end
=#

#Skipmer{U, A, M, N, K}(x::Skipmer{U, A, M, N, K}) where {U, A, M, N, K} = x

# Construct a LongSequence from a Skipmer.
#LongSequence{A}(x::Skipmer{U, DNAAlphabet{2}, M, N, K}) where {U, A<:DNAAlphabet, M, N, K} = LongSequence{A}([nt for nt in x])
#LongSequence{A}(x::Skipmer{U, RNAAlphabet{2}, M, N, K}) where {U, A<:RNAAlphabet, M, N, K} = LongSequence{A}([nt for nt in x])
#LongSequence(x::Skipmer{U, A, M, N, K}) where {U, A, M, N, K} = LongSequence{A}([nt for nt in x])

#Base.convert(::Type{U}, x::Skipmer{U, A, M, N, K}) where {U<:Unsigned, A, M, N, K} = encoded_data(x)