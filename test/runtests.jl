# Shark: Test Chess Engine
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
function perft(s::State, depth::Int)::Int
    nodes = 0
    if depth == 0 return 1; end
    for move in generate_legal_moves(s)
        x = make_move(s, move)
        nodes += perft(x, depth - 1)
    end
    return nodes;
end
