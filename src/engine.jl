# Shark: Chess Engine
export State
export print_legal_moves
export make_move, move_value

struct State
    board::Array{UInt8, 1} # position
    turn::UInt8            # white | black
    wc::Tuple{Bool, Bool}  # white castle rights: kingside | queenside
    bc::Tuple{Bool, Bool}  # black castle rights: kingside | queenside
    kp::UInt8              # castling square
    ep::UInt8              # enpassant square
    mc::Int                # move counter
end

function State(board::Vector{UInt8} = BOARD)
    return State(board, WHITE, (true, true), (true, true), NONE, NONE, 0)
end

@inline Base.getindex(s::State, i::Int) = s.board[i];
@inline Base.iterate(s::State, i::Int = 1) = i > 120 ? nothing : (s[i], i + 1);

function Base.show(io::IO, s::State)
    println(io, "\033[2J") # clear repl
    println(io, "\033[$(displaysize(stdout)[1])A")
    board = filter(x -> x ≠ OFF, s.board)
    player = s.turn == WHITE ? "White" : "Black"
    castle_rights = "" * (s.wc[1] ? "K" : "-") * (s.wc[2] ? "Q" : "-")
    castle_rights *= (s.bc[1] ? "k" : "-") * (s.bc[2] ? "q" : "-")
    ep_square = s.ep == 0 ? "-" : s.ep
    println(io, "  A B C D E F G H")
    for (i, j) in enumerate(1:8:64)
        rank = 8 - i + 1
        print(io, "$rank|")
        for k in j:j+7
            p = board[k]
            if p == NONE # empty board square
                square = rank % 2 == k % 2 ? '◼' : '◻'
                print(io, "$square ")
            else # unicode piece
                piece = PIECE[p]
                print(io, "$piece ")
            end
        end
        if     i == 1 println(io, " Turn:          $player        ")
        elseif i == 2 println(io, " Castle Rights: $castle_rights ")
        elseif i == 3 println(io, " Enpassant:     $ep_square     ")
        elseif i == 4 println(io, " Move Counter:  $(s.mc)        ")
        elseif i == 5 println(io, "  ___  _                _      ")
        elseif i == 6 println(io, " / __|| |_   __ _  _ _ | |__   ")
        elseif i == 7 println(io, " \\__ \\| ' \\ / _` || '_|| / /")
        elseif i == 8 println(io, " |___/|_||_|\\__,_||_|  |_\\_\\")
        else println(io)
        end
    end
    println(io, "  A B C D E F G H")
end

function gen_attacks(s::State)
    xside = opposite(s.turn)
    sqₓ = (U, U+U, D, D+D)
    Channel() do attacks
        for (i, p) in enumerate(s)
            if color(p) ≠ xside
                continue
            end
            type = class(p)
            for o in OFFSETS[p]
                for j in Iterators.countfrom(i + o, o)
                    q = s[j] # destination
                    if q == OFF || color(q) == xside
                        break # off board / own piece
                    end
                    if type == PAWN && o in sqₓ
                        break # ignore ↑ ↓ pawn moves
                    end
                    put!(attacks, j) # valid "threat"
                    if type in (PAWN, KNIGHT, KING) || color(q) ≠ xside
                        break # non-sliding piece or captured piece
                    end
                end
            end
        end
    end
end

function gen_moves(s::State)
    side, xside = s.turn, opposite(s.turn)
    # pawn conditions: enpassant, double move
    sqₓ = (s.ep, s.kp, s.kp + 1, s.kp - 1)
    f, dₓ, β = side == WHITE ? (<, U, A2) : (>, D, H7)
    # castling permission
    king, kₛ, qₛ, cr = side == WHITE ? (WK, H1, A1, s.wc) : (BK, H8, A8, s.bc)
    Channel() do moves
        for (i, p) in enumerate(s)
            if color(p) ≠ side
                continue
            end
            type = class(p)
            for o in OFFSETS[p]
                for j in Iterators.countfrom(i + o, o)
                    q = s[j] # destination
                    if q == OFF || color(q) == side
                        break # off board / own piece
                    end
                    if type == PAWN
                        if o in (dₓ, dₓ+dₓ) && q ≠ NONE
                            break # ↑ ↓ iff sq is empty
                        end
                        if o == (dₓ+dₓ) && (f(i,β) || s[i+dₓ] ≠ NONE)
                            break # check moving ↑ ↓ two spaces
                        end
                        if o in (dₓ+L, dₓ+R) && q == NONE && j ∉ sqₓ
                            break # ↖ ↘ ↗ ↙ attack check
                        end
                        # store pawn move
                        put!(moves, (i, j))
                        break
                    end
                    put!(moves, (i, j)) # store move
                    if type in (KNIGHT, KING) || color(q) == xside
                        break # non-sliding piece or captured piece
                    end
                    if i == kₛ && s[j+L] == king && cr[1]
                        # cannot kingside castle while or into check: E, F, G
                        if any(m -> m in (kₛ-3, kₛ-2, kₛ-1), gen_attacks(s))
                            break
                        end
                        put!(moves, (j+L, j+R))
                    elseif i == qₛ && s[j+R] == king && cr[2]
                        # cannot queenside castle while or into check: E, D, C
                        if any(m -> m in (qₛ+4, qₛ+3, qₛ+2), gen_attacks(s))
                            break
                        end
                        put!(moves, (j+R, j+L))
                    end
                end
            end
        end
    end
end

function print_moves(s::State)
    counter = 0
    for move in gen_moves(s)
        counter += 1
        from, to = move
        piece = PIECE[s[from]]
        println("Move $counter: $piece $from → $to")
    end
end

function make_move(s::State, move::Tuple{Int, Int})
    i, j = move
    p, q = s[i], s[j]
    board = copy(s.board)
    wc, bc, kp, ep = s.wc, s.bc, 0, 0
    board[j] = p
    board[i] = NONE
    # rook moved or captured
    if i == A1 || j == A1
        wc = (wc[1], false)
    end
    if i == H1 || j == H1
        wc = (false, wc[2])
    end
    if i == A8 || j == A8
        bc = (bc[1], false)
    end
    if i == H8 || j == H8
        bc = (false, bc[2])
    end
    if class(p) == KING
        if p == WK
            wc = (false, false)
        elseif p == BK
            bc = (false, false)
        end
        kₛ, qₛ, rook = s.turn == WHITE ? (H1, A1, WR) : (H8, A8, BR)
        if abs(j - i) == 2
            kp = (i + j) ÷ 2
            if j < i
                board[qₛ] = NONE
            else
                board[kₛ] = NONE
            end
            board[kp] = rook
        end
    elseif class(p) == PAWN
        dₓ = s.turn == WHITE ? U : D
        if A8 ≤ j ≤ H8 || A1 ≤ j ≤ H1
            queen = s.turn == WHITE ? WQ : BQ
            board[j] = queen
        elseif j - i == dₓ+dₓ
            ep = i + dₓ
        elseif j == s.ep
            board[j-dₓ] = NONE
        end
    end
    mc = s.mc + 1           # increment move counter
    turn = opposite(s.turn) # switch turns
    return State(board, turn, wc, bc, kp, ep, mc)
end

function move_value(s::State, move::Tuple{Int, Int})
    i, j = move
    p, q = s[i], s[j]
    king, ks, qs, rook = s.turn == WHITE ? (WK, H1, A1, WR) : (BK, H8, A8, BR)
    # pts = new position - old position
    pts = POSITION[p][j] - POSITION[p][i]
    # add points for capturing piece
    if q ≠ NONE
        pts += POSITION[q][j]
    end
    # add points for castling: king
    if abs(j - s.kp) < 2
        pts += POSITION[king][j]
    end
    # add points for castling: rook update
    if class(p) == KING && abs(i - j) == 2
        pts += POSITION[rook][(i + j) ÷ 2]
        sq = j < i ? qs : ks
        pts -= POSITION[rook][sq]
    elseif class(p) == PAWN
        dₓ = s.turn == WHITE ? U : D
        queen = s.turn == WHITE ? WQ : BQ
        if A8 ≤ j ≤ H8 || A1 ≤ j ≤ H1
            # add points for pawn promotion
            pts += POSITION[queen][j] - POSITION[p][j]
        elseif j == s.ep
            # add points for enpassant capture
            x = s.turn == WHITE ? BP : WP
            pts += POSITION[x][j-dₓ]
        end
    end
    return pts
end

function gen_legal_moves(s::State)
    Channel() do legal_moves
        # determine player king
        piece = s.turn == WHITE ? WK : BK
        for move in gen_moves(s)
            # make pseudo-legal move
            x = make_move(s, move)
            # find (updated) king position
            king = findfirst(x.board .== piece)
            if isnothing(king)
                continue
            end
            if !any(m -> king in m, gen_moves(x))
                put!(legal_moves, move)
            end
        end
    end
end

function print_legal_moves(s::State)
    counter = 0
    for move in gen_legal_moves(s)
        counter += 1
        from, to = move
        piece = PIECE[s[from]]
        println("Move $counter: $piece $from → $to")
    end
end
