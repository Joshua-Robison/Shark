using Test
using Shark

#=
    Depth     Nodes         Performance      Result
    -----   ---------   ------------------  --------
      0   →         1     0.000000 seconds     ✓
      1   →        20     0.001304 seconds     ✓
      2   →       400     0.027820 seconds     ✓
      3   →     8,902     0.591598 seconds     ✓
      4   →   197,281    14.038067 seconds     ✓
      5   → 4,865,609   352.093975 seconds     ✓
=#
function perft(s::State, depth::Int)
    nodes = 0
    if depth == 0 && return 1 end
    for move in gen_legal_moves(s)
        x = make_move(s, move)
        nodes += perft(x, depth - 1)
    end
    return nodes
end

@testset begin
    s = State()
    @test perft(s, 0) === 1
    @test perft(s, 1) === 20
    @test perft(s, 2) === 400
    @test perft(s, 3) === 8902
    @test perft(s, 4) === 197281
    # @test perft(s, 5) === 4865609
end
