# Shark: Chess Utilities
@inline color(p::UInt8) = p & -p;
@inline class(p::UInt8) = p & OFF;
@inline opposite(p::UInt8) = p ⊻ 3;
