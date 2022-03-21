require 'colorize'

WIN_COMBINATIONS = [
  [0, 1, 2], # row 1
  [3, 4, 5], # row 2
  [6, 7, 8], # row 3
  [0, 3, 6], # left column
  [1, 4, 7], # middle column
  [2, 5, 8], # right column
  [0, 4, 8], # left diagonal
  [2, 4, 6]  # right diagonal
]

score = { user: 0, computer: 0 }

def clear
  puts "amit"
  if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
    system('cls')
  else
    system('clear')
  end
end

def prompt(message)
  puts("=> #{message}")
end

# TITLE animation code
def animate(strings)
  strings.each do |str|
    str.each_char do |letter|
      print letter
      sleep(0.04)
    end
  end
  puts ""
  puts ""
end

def start_game
  clear
  str = "You are #{'BLUE'.blue}. Computer is #{'RED'.red}."
  animate(["Welcome to my lesson 6 assignment: ", "TIC-TAC-TOE!"])
  sleep(0.5)
  animate(["First to 5 wins. ", str])
  sleep(0.5)
  prompt('Press any key to start')
  gets
end

# BOARD display
def puts_board_lines
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
end

def puts_board_items(gameboard, row)
  board = adjust_board_display(gameboard)
  case row
  when 1 then puts "  #{board[0]}  |  #{board[1]}  | #{board[2]}  "
  when 2 then puts "  #{board[3]}  |  #{board[4]}  | #{board[5]}  "
  when 3 then puts "  #{board[6]}  |  #{board[7]}  | #{board[8]}  "
  end
end

def adjust_board_display(board)
  board.map do |i|
    if i.is_a? Integer
      (i + 1).to_s.light_black
    else
      i
    end
  end
end

def display_board(board)
  clear
  puts "     |     |     "
  puts_board_items(board, 1)
  puts_board_lines
  puts_board_items(board, 2)
  puts_board_lines
  puts_board_items(board, 3)
  puts "     |     |     "
  puts ""
end

# BOARD data
def empty_squares(board)
  board.select { |sqr| sqr.is_a? Numeric }
end

def joinor(board, delimiter = ', ', word = 'or')
  numbers = empty_squares(board).map { |num| num + 1 }
  separator_array = []
  if numbers.size < 3
    numbers = numbers.join(' or ')
  else
    numbers.each_with_index do |num, idx|
      if numbers.size > (idx + 1)
        separator_array << num
      else
        numbers = "#{separator_array.join(delimiter)} #{word} #{numbers.last}"
      end
    end
  end
  numbers.light_black
end

def input_to_index(user_input)
  user_input.to_i - 1
end

def player_squares(board, user_piece)
  player = []
  board.each_with_index do |sqr, idx|
    player << idx if sqr == user_piece.blue
  end
  player
end

def computer_squares(board, computer_piece)
  computer = []
  board.each_with_index do |sqr, idx|
    computer << idx if sqr == computer_piece.red
  end
  computer
end

def someone_won?(board, assigned_pieces)
  pieces = ['X', 'O']
  user_piece = pieces[assigned_pieces[0]]
  computer_piece = pieces[assigned_pieces[1]]
  user = player_squares(board, user_piece)
  computer = computer_squares(board, computer_piece)
  WIN_COMBINATIONS.each do |win_combination|
    return 1 if (win_combination - user).empty?
    return 2 if (win_combination - computer).empty?
  end
  false
end

def board_full?(board)
  return true if empty_squares(board).empty?
  false
end

# PLAYER AND COMPUTER GAMEPLAY
def player_places_piece!(board, user_piece)
  user_input = ""
  loop do
    prompt("Choose a position to place X: #{joinor(board)}")
    user_input = input_to_index(gets.chomp)
    break if board.include?(user_input)
    prompt("Oops! Please pick a valid and empty square space.")
  end
  board[user_input] = user_piece.blue
  display_board(board)
end

def ai_offense(board, computer_piece)
  computer_squares = computer_squares(board, computer_piece)
  WIN_COMBINATIONS.each do |win_combination|
    ai_remain = win_combination - computer_squares
    if ai_remain.size == 1
      return ai_remain[0] if board.include?(ai_remain[0])
    end
  end
  "no"
end

def ai_defense(board, user_piece)
  player_squares = player_squares(board, user_piece)
  WIN_COMBINATIONS.each do |win_combination|
    remain = win_combination - player_squares
    if remain.size == 1
      return remain[0] if board.include?(remain[0])
    end
  end
  "no"
end

def ai_picks_piece(board, user_piece, computer_piece)
  return 4 if board.include?(4) && empty_squares(board) == 8
  return board[0] if board.size == 1
  ai_attack = ai_offense(board, computer_piece)
  ai_defend = ai_defense(board, user_piece)
  return ai_attack if ai_attack != 'no'
  return ai_defend if ai_defend != 'no'
  empty_squares(board).sample
end

def computer_places_piece!(board, user, computer_piece)
  computer = ai_picks_piece(board, user, computer_piece)
  sleep(0.2)
  board[computer] = computer_piece.red
  display_board(board)
end

def place_piece!(board, assigned_pieces, current_player)
  pieces = ['X', 'O']
  user = pieces[assigned_pieces[0]]
  computer = pieces[assigned_pieces[1]]
  case current_player
  when "user" then player_places_piece!(board, user)
  when "computer" then computer_places_piece!(board, user, computer)
  end
end

def alternate_player(current_player)
  current_player == "user" ? "computer" : "user"
end

def assign_pieces(current_player)
  case current_player
  when "user" then [0, 1]
  when "computer" then [1, 0]
  end
end

# DISPLAY RESULTS & CHECK/UPDATE SCORE
def display_updated_results(board, assigned_pieces, score)
  case someone_won?(board, assigned_pieces)
  when 1
    prompt('You win!'.green)
    score[:user] += 1
  when 2
    prompt('You lose!'.red)
    score[:computer] += 1
  end
  prompt('Tie!'.yellow) if board_full?(board)
  prompt("Score: Player #{score[:user].to_s.blue}" \
    " - Computer #{score[:computer].to_s.red}")
end

def final_score_reached?(score)
  if score[:user] == 5
    prompt("You're the grand winner!")
    return true
  elsif score[:computer] == 5
    prompt("Computer is the grand winner!")
    return true
  end
  false
end

# MAIN GAME LOOP
start_game
loop do
  board = [0, 1, 2, 3, 4, 5, 6, 7, 8]
  current_player = ["user", "computer"].sample
  assigned_pieces = assign_pieces(current_player)

  # user/computer turn loop
  loop do
    display_board(board)
    place_piece!(board, assigned_pieces, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(board, assigned_pieces) || board_full?(board)
  end

  display_updated_results(board, assigned_pieces, score)
  sleep 1

  # score check
  if final_score_reached?(score)
    prompt("Would you like to play again? (Y/N)")
    answer = gets.chomp
    break if answer.downcase != 'y'
    score[:user] = 0
    score[:computer] = 0
  end
  sleep 0.2
end

prompt("Thank you for playing! Goodbye!")
