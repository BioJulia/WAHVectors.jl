module WAHTest

using Test
using WAHVectors

function make_random_bitvector(n0, nF, nX, nshuffle)
    v = Vector{UInt32}(n0 + nF + nX)
    aR = rand(0x00000000:0xFFFFFFFF, nX)
    i = 1
    for _ in 1:n0
        v[i] = 0x00000000
        i += 1
    end
    for _ in 1:nF
        v[i] = 0xFFFFFFFF
        i += 1
    end
    for j in 1:nX
        v[i] = aR[j]
    end
    for _ in 1:nshuffle
        shuffle!(v)
    end
    return v
end

@testset "Internals" begin
    @testset "WAH Vector Elements" begin
        @testset "Constructors" begin
            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                @test WAHVectors.WAHElement(0x00000000, n) == convert(WAHVectors.WAHElement, 0x80000000 + n)
                @test WAHVectors.WAHElement(0x00000001, n) == convert(WAHVectors.WAHElement, 0xC0000000 + n)
            end
        end
        @testset "isruns" begin
            @test !WAHVectors.isruns(WAHVectors.WAH_LITERAL_ZEROS)
            @test !WAHVectors.isruns(WAHVectors.WAH_LITERAL_ONES)
            @test WAHVectors.isruns(WAHVectors.WAH_FULL_ZEROS)
            @test WAHVectors.isruns(WAHVectors.WAH_FULL_ONES)

            @test !WAHVectors.is_zeros_runs(WAHVectors.WAH_LITERAL_ZEROS)
            @test !WAHVectors.is_zeros_runs(WAHVectors.WAH_LITERAL_ONES)
            @test WAHVectors.is_zeros_runs(WAHVectors.WAH_FULL_ZEROS)
            @test !WAHVectors.is_zeros_runs(WAHVectors.WAH_FULL_ONES)

            @test !WAHVectors.is_ones_runs(WAHVectors.WAH_LITERAL_ZEROS)
            @test !WAHVectors.is_ones_runs(WAHVectors.WAH_LITERAL_ONES)
            @test !WAHVectors.is_ones_runs(WAHVectors.WAH_FULL_ZEROS)
            @test WAHVectors.is_ones_runs(WAHVectors.WAH_FULL_ONES)

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)
                el = WAHVectors.WAHElement(rand(0x00000000:0x7FFFFFFF))

                @test WAHVectors.isruns(e0)
                @test WAHVectors.isruns(e1)
                @test !WAHVectors.isruns(el)
                @test WAHVectors.is_zeros_runs(e0)
                @test !WAHVectors.is_zeros_runs(e1)
                @test !WAHVectors.is_zeros_runs(el)
                @test !WAHVectors.is_ones_runs(e0)
                @test WAHVectors.is_ones_runs(e1)
                @test !WAHVectors.is_ones_runs(el)
            end
        end
        @testset "isliteral" begin
            @test WAHVectors.isliteral(WAHVectors.WAH_LITERAL_ZEROS)
            @test WAHVectors.isliteral(WAHVectors.WAH_LITERAL_ONES)
            @test !WAHVectors.isliteral(WAHVectors.WAH_FULL_ZEROS)
            @test !WAHVectors.isliteral(WAHVectors.WAH_FULL_ONES)

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)
                el = WAHVectors.WAHElement(rand(0x00000000:0x7FFFFFFF))

                @test !WAHVectors.isliteral(e0)
                @test !WAHVectors.isliteral(e1)
                @test WAHVectors.isliteral(el)
            end
        end
        @testset "nwords" begin
            @test WAHVectors.nwords(WAHVectors.WAH_LITERAL_ZEROS) == 1
            @test WAHVectors.nwords(WAHVectors.WAH_LITERAL_ONES) == 1
            @test WAHVectors.nwords(WAHVectors.WAH_FULL_ZEROS) == WAHVectors.WAH_MAX_NRUNS
            @test WAHVectors.nwords(WAHVectors.WAH_FULL_ONES) == WAHVectors.WAH_MAX_NRUNS

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)
                el = WAHVectors.WAHElement(rand(0x00000000:0x7FFFFFFF))

                @test WAHVectors.nwords(e0) == n
                @test WAHVectors.nwords(e1) == n
                @test WAHVectors.nwords(el) == 0x00000001
            end
        end
        @testset "runval" begin
            @test WAHVectors.runval(WAHVectors.WAH_FULL_ZEROS) == 0x00000000
            @test WAHVectors.runval(WAHVectors.WAH_FULL_ONES) == 0x00000001

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.runval(e0) == 0x00000000
                @test WAHVectors.runval(e1) == 0x00000001
            end
        end
        @testset "nruns" begin
            @test WAHVectors.nruns(WAHVectors.WAH_FULL_ZEROS) == WAHVectors.WAH_MAX_NRUNS
            @test WAHVectors.nruns(WAHVectors.WAH_FULL_ONES) == WAHVectors.WAH_MAX_NRUNS

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.nruns(e0) == n
                @test WAHVectors.nruns(e1) == n
            end
        end
        @testset "nfree" begin
            @test WAHVectors.nfree(WAHVectors.WAH_FULL_ZEROS) == 0
            @test WAHVectors.nfree(WAHVectors.WAH_FULL_ONES) == 0

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.nfree(e0) == (WAHVectors.WAH_MAX_NRUNS - n)
                @test WAHVectors.nfree(e1) == (WAHVectors.WAH_MAX_NRUNS - n)
            end
        end
        @testset "isfull" begin
            @test WAHVectors.isfull(WAHVectors.WAH_FULL_ZEROS)
            @test WAHVectors.isfull(WAHVectors.WAH_FULL_ONES)

            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.isfull(e0) == (WAHVectors.WAH_MAX_NRUNS == n)
                @test WAHVectors.isfull(e1) == (WAHVectors.WAH_MAX_NRUNS == n)
            end
        end
        @testset "hasroom" begin
            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                s = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                e = WAHVectors.WAHElement(0x00000000, n)
                @test WAHVectors.hasroom(e) == (n < WAHVectors.WAH_MAX_NRUNS)
                @test WAHVectors.hasroom(e, s) == (s <= WAHVectors.nfree(e))
            end
        end
        @testset "matchingfills" begin
            for _ in 1:100
                n1 = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                n2 = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                v1 = rand(0x00000000:0x00000001)
                v2 = rand(0x00000000:0x00000001)

                @test WAHVectors.matchingfills(WAHVectors.WAHElement(v1, n1), WAHVectors.WAHElement(v2, n2)) == (v1 == v2)
            end
        end
        @testset "increment_nruns_unsafe" begin
            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                i = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                v = rand(0x00000000:0x00000001)
                e = WAHVectors.WAHElement(v, n)
                @test WAHVectors.increment_nruns_unsafe(e) == WAHVectors.WAHElement(UInt32(e) + UInt32(1))
                @test WAHVectors.increment_nruns_unsafe(e, i) == WAHVectors.WAHElement(UInt32(e) + i)
            end
        end
        @testset "runfill" begin
            for _ in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NRUNS)
                v = rand(0x00000000:0x00000001)
                e1 = WAHVectors.WAHElement(v, n)
                @test WAHVectors.runfill(e1) == ifelse(v == 0x00000001, 0x7FFFFFFF, 0x00000000)
            end
        end
    end
#=
    @testset "WAHVectors" begin
        @testset "round trip" begin
            bv = make_random_bitvector(10, 20, 10, 5)
            @test convert(Vector{UInt32}, WAHVector(bv)) == bv
        end
    end
=#
end

end
