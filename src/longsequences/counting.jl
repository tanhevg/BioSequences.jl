###
### LongSequence specific specializations of src/biosequence/counting.jl
###

# Counting GC positions
let
    @info "Compiling bit-parallel GC counter for LongSequence{<:NucleicAcidAlphabet}"
    counter = :(n += gc_bitcount(chunk, BitsPerSymbol(seq)))
    compile_bitpar(
        :count_gc_bitpar,
        arguments   = (:(seq::LongSequence{<:NucleicAcidAlphabet}),),
        init_code   = :(n = 0),
        head_code   = counter,
        body_code   = counter,
        tail_code   = counter,
        return_code = :(return n)
    ) |> eval
end

Base.count(::typeof(isGC), seq::LongSequence{<:NucleicAcidAlphabet}) = count_gc_bitpar(seq)

# Counting mismatches
let
    @info "Compiling bit-parallel mismatch counter for LongSequence{<:NucleicAcidAlphabet}"
    counter = :(count += mismatch_bitcount(x, y, A()))
    compile_2seq_bitpar(
        :count_mismatches_bitpar,
        arguments = (:(seqa::LongSequence{A}), :(seqb::LongSequence{A})),
        parameters = (:(A<:NucleicAcidAlphabet),),
        init_code = :(count = 0),
        head_code = counter,
        body_code = counter,
        tail_code = counter,
        return_code = :(return count)
    ) |> eval
end
count_mismatches_bitpar(seqa::LongSequence, seqb::LongSequence) = count_mismatches_bitpar(promote(seqa, seqb)...)

Base.count(::typeof(!=), seqa::LongSequence{A}, seqb::LongSequence{A}) where {A<:NucleicAcidAlphabet} = count_mismatches_bitpar(seqa, seqb)
