require "yaml"

# CONSTANTS

MSG = YAML.load_file('ttt_messages.yml')
INITIAL_MARKER = " "
PLAYER_MARKER = "X"
COMPUTER_MARKER = "O"
WINNING_SCORE = 5
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                [[1, 5, 9], [3, 5, 7]]              # diagonals

# SCORE AND INFO DISPLAY
# -----------------------

def prompt(msg)
  puts "=> #{msg}"
end

def bar_animation(speed)
  puts("")
  puts("")
  25.times do
    print(":")
    sleep(speed)
  end
  puts("")
  puts("")
end

def letter_animation(message)
  message.each_char do |c|
    print c
    sleep(0.05)
  end
end

def joinor(arr, delimiter=", ", connector="or")
  case arr.size
  when 0 then ""
  when 1 then arr.first
  when 2 then arr.join(" #{connector} ")
  else
    arr[-1] = "#{connector} #{arr.last}"
    arr.join(delimiter)
  end
end

def keep_score!(brd, score)
  case detect_winner(brd)
  when "Player" then score[:player] += 1
  when "Computer" then score[:computer] += 1
  else score[:ties] += 1
  end
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def display_score(score)
  puts ""
  bar_animation(0.02)
  letter_animation(" F I N A L   S C O R E ")
  sleep(1)
  puts ""
  puts ""
  letter_animation("Player: #{score[:player]}")
  sleep(1)
  puts ""
  letter_animation("Computer: #{score[:computer]}")
  sleep(1)
  puts ""
  letter_animation("Ties: #{score[:ties]}")
  sleep(1)
  bar_animation(0.02)
  puts ""
end
# rubocop:enable Metrics/MethodLength

# BOARD DISPLAY & BOARD DYNAMICS
# ----------------

def display_board(brd)
  system "clear"
  puts "You're a #{PLAYER_MARKER}. Computer is a #{COMPUTER_MARKER}"
  puts ""
  puts "     |     |     "
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}  "
  puts "     |     |     "
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def find_at_risk_square(line, brd, marker)
  if brd.values_at(*line).count(marker) == 2
    brd.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

# GAMEPLAY
# -------------------------

# rubocop:disable Metrics/MethodLength
def play_sequence
  answer = ""
  loop do
    prompt(MSG["who_plays_first"])
    answer = gets.chomp.downcase
    (answer = "user") if ["u", "user"].include?(answer)
    (answer = "computer") if ["c", "computer"].include?(answer)
    (answer = "random") if ["r", "random"].include?(answer)

    case answer
    when "user" then return "user"
    when "computer" then return "computer"
    when "random" then return ["user", "computer"].sample
    else
      prompt(MSG["try_again"])
    end
  end
  answer
end
# rubocop:enable Metrics/MethodLength

def alternate_turns(current_player)
  if current_player == "user"
    current_player = "computer"
  elsif current_player == "computer"
    current_player = "user"
  end
end

def place_piece!(brd, current_player)
  current_player == "user" ? user_places_piece!(brd) : computer_places_piece!(brd)
end

def user_places_piece!(brd)
  square = " "

  loop do
    prompt "Choose a square: #{joinor(empty_squares(brd))}"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt(MSG["not_valid"])
  end
  brd[square] = PLAYER_MARKER
end

def computer_places_piece!(brd)
  square = if computer_offense(brd)
             computer_offense(brd)
           elsif computer_defense(brd)
             computer_defense(brd)
           elsif pick_square_5(brd)
           else
             computer_plays_randomly(brd)
           end

  brd[square] = COMPUTER_MARKER
end

def computer_defense(brd)
  square = " "
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, PLAYER_MARKER)
    break if square
  end
  square
end

def computer_offense(brd)
  square = " "
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, COMPUTER_MARKER)
    break if square
  end
  square
end

def pick_square_5(brd)
  square = " "
  if brd[5] == INITIAL_MARKER
    brd[5] = COMPUTER_MARKER
  else
    square = nil
  end
  square
end

def computer_plays_randomly(brd)
  empty_squares(brd).sample
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return "Player"
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return "Computer"
    end
  end
  nil
end

# MAIN GAME LOOP
system("clear")
bar_animation(0.05)
letter_animation("Welcome to TIC-TAC-TOE!")
bar_animation(0.05)
sleep(1)
loop do # main loop (outermost loop)
  current_player = play_sequence
  first_move = current_player

  score = { player: 0, computer: 0, ties: 0 }

  loop do # individual round loop
    board = initialize_board
    display_board(board)

    loop do # gameplay loop
      display_board(board)
      prompt " "
      prompt "SCORE: Player #{score[:player]}, Computer #{score[:computer]}"
      place_piece!(board, current_player)
      current_player = alternate_turns(current_player)
      break if someone_won?(board) || board_full?(board)
    end

    keep_score!(board, score)
    if someone_won?(board)
      prompt "#{detect_winner(board)} won!"
    else
      prompt "It's a tie!"
    end

    break if score[:player] == WINNING_SCORE ||
             score[:computer] == WINNING_SCORE
    current_player = alternate_turns(first_move)
    first_move = current_player
  end

  display_score(score)

  prompt(MSG["play_again"])
  sleep(2)
  answer = gets.chomp.upcase
  break unless answer.start_with?("Y")
end

prompt(MSG["thanks"])
