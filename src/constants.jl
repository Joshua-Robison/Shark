# Shark: Chess Constants
const WHITE  = UInt8(1)      # 0000 0001
const BLACK  = UInt8(1) << 1 # 0000 0010
const PAWN   = UInt8(1) << 2 # 0000 0100
const KNIGHT = UInt8(1) << 3 # 0000 1000
const BISHOP = UInt8(1) << 4 # 0001 0000
const ROOK   = UInt8(1) << 5 # 0010 0000
const QUEEN  = UInt8(1) << 6 # 0100 0000
const KING   = UInt8(1) << 7 # 1000 0000

# Off Board and No Piece
const OFF  = UInt8(252) # 1111 1100
const NONE = UInt8(0)   # 0000 0000

# Pieces → COLOR | CLASS
const WP, BP = WHITE | PAWN,   BLACK | PAWN
const WN, BN = WHITE | KNIGHT, BLACK | KNIGHT
const WB, BB = WHITE | BISHOP, BLACK | BISHOP
const WR, BR = WHITE | ROOK,   BLACK | ROOK
const WQ, BQ = WHITE | QUEEN,  BLACK | QUEEN
const WK, BK = WHITE | KING,   BLACK | KING

# Unicode Representation
const PIECE = Dict{UInt8, Char}(
    WP => '\u2659', BP => '\u265F', # Pawn   ♙ | ♟
    WN => '\u2658', BN => '\u265E', # Knight ♘ | ♞
    WB => '\u2657', BB => '\u265D', # Bishop ♗ | ♝
    WR => '\u2656', BR => '\u265C', # Rook   ♖ | ♜
    WQ => '\u2655', BQ => '\u265B', # Queen  ♕ | ♛
    WK => '\u2654', BK => '\u265A'  # King   ♔ | ♚
)

# Piece Move Offsets
const U, D, L, R = Int8(-10), Int8(10), Int8(-1), Int8(1)
const OFFSETS = Dict{UInt8, Tuple{Int8, Vararg}}(
    # White Pieces
    WP => (U, U+U, U+L, U+R),
    WN => (U+U+R, U+R+R, D+R+R, D+D+R, D+D+L, D+L+L, U+L+L, U+U+L),
    WB => (U+R, D+R, D+L, U+L),
    WR => (U, D, L, R),
    WQ => (U, D, L, R, U+R, D+R, D+L, U+L),
    WK => (U, D, L, R, U+R, D+R, D+L, U+L),
    # Black Pieces
    BP => (D, D+D, D+L, D+R),
    BN => (U+U+R, U+R+R, D+R+R, D+D+R, D+D+L, D+L+L, U+L+L, U+U+L),
    BB => (U+R, D+R, D+L, U+L),
    BR => (U, D, L, R),
    BQ => (U, D, L, R, U+R, D+R, D+L, U+L),
    BK => (U, D, L, R, U+R, D+R, D+L, U+L)
)

# Mailbox 12x10 Board Representation
const A1, A2, A8 = Int8(92), Int8(82), Int8(22)
const H1, H7, H8 = Int8(99), Int8(39), Int8(29)
const BOARD = "          " * #       A B C D E F G H         1 - 10
              "          " * #                              11 - 20
              " rnbqkbnr " * #   8   r n b q k b n r   8    21 - 30
              " pppppppp " * #   7   p p p p p p p p   7    31 - 40
              " ........ " * #   6   . . . . . . . .   6    41 - 50
              " ........ " * #   5   . . . . . . . .   5    51 - 60
              " ........ " * #   4   . . . . . . . .   4    61 - 70
              " ........ " * #   3   . . . . . . . .   3    71 - 80
              " PPPPPPPP " * #   2   P P P P P P P P   2    81 - 90
              " RNBQKBNR " * #   1   R N B Q K B N R   1    91 - 100
              "          " * #                             101 - 110
              "          "   #       A B C D E F G H       111 - 120

# Piece Values
const VALUE = Dict{UInt8, Int}(
    WP => 100,   BP => 100,   # Pawn   ♙ | ♟ = 100
    WN => 300,   BN => 300,   # Knight ♘ | ♞ = ♙♙♙
    WB => 300,   BB => 300,   # Bishop ♗ | ♝ = ♙♙♙
    WR => 500,   BR => 500,   # Rook   ♖ | ♜ = ♙♙♙♙♙
    WQ => 900,   BQ => 900,   # Queen  ♕ | ♛ = ♙♙♙♙♙♙♙♙♙
    WK => 50000, BK => 50000, # King   ♔ | ♚ = ~Infinity
)

# TODO: Add Piece Heuristics

# Position Heuristics
const POSITION = Dict{UInt8, Array{Int, 1}}(
    # White Pieces
    WP => VALUE[WP] .+ zeros(120),
    WN => VALUE[WN] .+ zeros(120),
    WB => VALUE[WB] .+ zeros(120),
    WR => VALUE[WR] .+ zeros(120),
    WQ => VALUE[WQ] .+ zeros(120),
    WK => VALUE[WK] .+ zeros(120),
    # Black Pieces
    BP => VALUE[BP] .+ zeros(120),
    BN => VALUE[BN] .+ zeros(120),
    BB => VALUE[BB] .+ zeros(120),
    BR => VALUE[BR] .+ zeros(120),
    BQ => VALUE[BQ] .+ zeros(120),
    BK => VALUE[BK] .+ zeros(120)
)
