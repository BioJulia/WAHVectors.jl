module WAHTest

using Base.Test

using WAHVectors

@testset "WAH Vector Elements" begin
    @testset "Constructors" begin
        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            @test WAHElement(0x00000000, n) == reinterpret(WAHElement, 0x80000000 + n)
            @test WAHElement(0x00000001, n) == reinterpret(WAHElement, 0xC0000000 + n)
        end
    end
    @testset "iscompressed" begin
        @test !isruns(WAH_LITERAL_ZEROS)
        @test !isruns(WAH_LITERAL_ONES)
        @test isruns(WAH_FULL_ZEROS)
        @test isruns(WAH_FULL_ONES)

        @test !is_zeros_runs(WAH_LITERAL_ZEROS)
        @test !is_zeros_runs(WAH_LITERAL_ONES)
        @test is_zeros_runs(WAH_FULL_ZEROS)
        @test !is_zeros_runs(WAH_FULL_ONES)

        @test !is_ones_runs(WAH_LITERAL_ZEROS)
        @test !is_ones_runs(WAH_LITERAL_ONES)
        @test !is_ones_runs(WAH_FULL_ZEROS)
        @test is_ones_runs(WAH_FULL_ONES)

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)
            el = WAHElement(rand(0x00000000:0x7FFFFFFF))

            @test isruns(e0)
            @test isruns(e1)
            @test !isruns(el)
            @test is_zeros_runs(e0)
            @test !is_zeros_runs(e1)
            @test !is_zeros_runs(el)
            @test !is_ones_runs(e0)
            @test is_ones_runs(e1)
            @test !is_ones_runs(el)
        end
    end
    @testset "isliteral" begin
        @test isliteral(WAH_LITERAL_ZEROS)
        @test isliteral(WAH_LITERAL_ONES)
        @test !isliteral(WAH_FULL_ZEROS)
        @test !isliteral(WAH_FULL_ONES)

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)
            el = WAHElement(rand(0x00000000:0x7FFFFFFF))

            @test !isliteral(e0)
            @test !isliteral(e1)
            @test isliteral(el)
        end
    end
    @testset "nwords" begin
        @test nwords(WAH_LITERAL_ZEROS) == 1
        @test nwords(WAH_LITERAL_ONES) == 1
        @test nwords(WAH_FULL_ZEROS) == WAH_MAX_NWORDS
        @test nwords(WAH_FULL_ONES) == WAH_MAX_NWORDS

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)
            el = WAHElement(rand(0x00000000:0x7FFFFFFF))

            @test nwords(e0) == n
            @test nwords(e1) == n
            @test nwords(el) == 0x00000001
        end
    end
    @testset "runval" begin
        @test runval(WAH_FULL_ZEROS) == 0x00000000
        @test runval(WAH_FULL_ONES) == 0x00000001

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)

            @test runval(e0) == 0x00000000
            @test runval(e1) == 0x00000001
        end
    end
    @testset "nruns" begin
        @test nruns(WAH_FULL_ZEROS) == WAH_MAX_NWORDS
        @test nruns(WAH_FULL_ONES) == WAH_MAX_NWORDS

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)

            @test nruns(e0) == n
            @test nruns(e1) == n
        end
    end
    @testset "nfree" begin
        @test nfree(WAH_FULL_ZEROS) == 0
        @test nfree(WAH_FULL_ONES) == 0

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)

            @test nfree(e0) == (WAH_MAX_NWORDS - n)
            @test nfree(e1) == (WAH_MAX_NWORDS - n)
        end
    end
    @testset "isfull" begin
        @test isfull(WAH_FULL_ZEROS)
        @test isfull(WAH_FULL_ONES)

        for i in 1:100
            n = rand(0x00000001:WAH_MAX_NWORDS)
            e0 = WAHElement(0x00000000, n)
            e1 = WAHElement(0x00000001, n)

            @test isfull(e0) == (WAH_MAX_NWORDS == n)
            @test isfull(e1) == (WAH_MAX_NWORDS == n)
        end
    end
end

#=
@testset "WAH Vectors" begin

end
=#

end
