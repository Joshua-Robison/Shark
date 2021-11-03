# Shark: Chess Utilities
@inline color(p::UInt8)::UInt8 = p & -p;
@inline class(p::UInt8)::UInt8 = p & OFF;
@inline opposite(p::UInt8)::UInt8 = p ⊻ 3;

# Piece "Constructor"
function piece(x::Char = '.')::UInt8
    color = islowercase(x) ? BLACK : WHITE
    class = lowercase(x)
    if class == 'p'
        return color | PAWN;
    elseif class == 'n'
        return color | KNIGHT;
    elseif class == 'b'
        return color | BISHOP;
    elseif class == 'r'
        return color | ROOK;
    elseif class == 'q'
        return color | QUEEN;
    elseif class == 'k'
        return color | KING;
    elseif class == '.'
        return NONE;
    else # class == ' '
        return OFF;
    end
end
