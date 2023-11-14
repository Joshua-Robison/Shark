# Shark: Chess Constants
const NONE   = 0x00      # 0000 0000
const WHITE  = 0x01      # 0000 0001
const BLACK  = 0x01 << 1 # 0000 0010
const PAWN   = 0x01 << 2 # 0000 0100
const KNIGHT = 0x01 << 3 # 0000 1000
const BISHOP = 0x01 << 4 # 0001 0000
const ROOK   = 0x01 << 5 # 0010 0000
const QUEEN  = 0x01 << 6 # 0100 0000
const KING   = 0x01 << 7 # 1000 0000
const OFF    = 0xfc      # 1111 1100

# Pieces → COLOR | CLASS
const WP, BP = WHITE | PAWN,   BLACK | PAWN
const WN, BN = WHITE | KNIGHT, BLACK | KNIGHT
const WB, BB = WHITE | BISHOP, BLACK | BISHOP
const WR, BR = WHITE | ROOK,   BLACK | ROOK
const WQ, BQ = WHITE | QUEEN,  BLACK | QUEEN
const WK, BK = WHITE | KING,   BLACK | KING

# Unicode Representation
const PIECE = Dict(
    WP => '\u2659', BP => '\u265F', # Pawn   ♙ | ♟
    WN => '\u2658', BN => '\u265E', # Knight ♘ | ♞
    WB => '\u2657', BB => '\u265D', # Bishop ♗ | ♝
    WR => '\u2656', BR => '\u265C', # Rook   ♖ | ♜
    WQ => '\u2655', BQ => '\u265B', # Queen  ♕ | ♛
    WK => '\u2654', BK => '\u265A'  # King   ♔ | ♚
)

# Piece Move Offsets
const U, D, L, R = -10, 10, -1, 1
const OFFSETS = Dict(
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
const A1, A2, A8 = 92, 82, 22
const H1, H7, H8 = 99, 39, 29
#
#       A B C D E F G H         1 - 10
#                              11 - 20
#   8   r n b q k b n r   8    21 - 30
#   7   p p p p p p p p   7    31 - 40
#   6   . . . . . . . .   6    41 - 50
#   5   . . . . . . . .   5    51 - 60
#   4   . . . . . . . .   4    61 - 70
#   3   . . . . . . . .   3    71 - 80
#   2   P P P P P P P P   2    81 - 90
#   1   R N B Q K B N R   1    91 - 100
#                             101 - 110
#       A B C D E F G H       111 - 120
#
const BOARD = OFF * ones(UInt8, 120)
BOARD[22:29] .= BR, BN, BB, BQ, BK, BB, BN, BR
BOARD[32:39] .= BP
BOARD[42:49] .= NONE
BOARD[52:59] .= NONE
BOARD[62:69] .= NONE
BOARD[72:79] .= NONE
BOARD[82:89] .= WP
BOARD[92:99] .= WR, WN, WB, WQ, WK, WB, WN, WR

# Piece Values
const VALUE = Dict(
    WP => 100,   BP => 100,  # Pawn   ♙ | ♟ = 100
    WN => 300,   BN => 300,  # Knight ♘ | ♞ = ♙♙♙
    WB => 300,   BB => 300,  # Bishop ♗ | ♝ = ♙♙♙
    WR => 500,   BR => 500,  # Rook   ♖ | ♜ = ♙♙♙♙♙
    WQ => 900,   BQ => 900,  # Queen  ♕ | ♛ = ♙♙♙♙♙♙♙♙♙
    WK => 50000, BK => 50000 # King   ♔ | ♚ = ~Infinity
)

# TODO: Add Piece Heuristics

# Position Heuristics
const POSITION = Dict(
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
