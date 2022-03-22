require 'rainbow'
require 'numbers_in_words'
require 'titleize'

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

# RETURN COLORED TEXT, NO PROMPT IF PROMPT = 0
def colorize(string, idx, prompt = 1)
  colors = [:red, :blue, :yellow, :green, :white, :gold, :goldenrod]
  if prompt == 1
    prompt Rainbow(string).bright.color(colors[idx])
  else
    Rainbow(string).bright.color(colors[idx])
  end
end

# ADDS EACH SUIT ICON TO TERMINAL DISPLAY
def add_suit_icon(suit)
  case suit
  when 'H' then Rainbow("\u{2665}").crimson.bg(:whitesmoke)
  when 'D' then Rainbow("\u{2666}").crimson.bg(:whitesmoke)
  when 'S' then Rainbow("\u{2660}").black.bg(:whitesmoke)
  when 'C' then Rainbow("\u{2663}").black.bg(:whitesmoke)
  when 'NA' then Rainbow("\u{1F0A0}").bg(:goldenrod)
  end
end

# WELCOME ANIMATION
def animate_title(title, idx)
  colored = Rainbow(title).black.bright.bg(:whitesmoke)
  titles = [colored, title]
  titles[idx].each_char do |letter|
    print letter
    sleep(0.05)
  end
  puts ""
end

def animate_suits
  suits = ['H', 'D', 'S', 'C']
  icons = []
  26.times { icons << add_suit_icon(suits.sample) }
  icons.each do |icon|
    print icon
    sleep(0.05)
  end
end

def animate_intro
  clear
  animate_suits
  print("\r")
  animate_title("  Welcome to Whatever-One!  ", 0)
  sleep(0.5)
  puts ""
end

# SET GAME NUMBER
def set_game_number
  animate_title('=> Pick a game number from 21-51:', 1)
  game_number = 0
  loop do
    game_number = gets.chomp.to_i
    break if (21..51).include?(game_number)
    prompt "Please pick a valid number"
  end
  game_number
end

def animate_game_number
  num_to_wrd = NumbersInWords.in_words(GAME_NUMBER)
  num_wrd = colorize(num_to_wrd.titleize, 6, 0)
  animate_title("=> You picked #{num_wrd}!", 1)
  animate_title('=> Press any key to start...', 1)
  gets
end

def init_deck
  deck = []
  face_cards = ['A', 'J', 'Q', 'K']
  suits = ['H', 'C', 'S', 'D']
  suits.each do |suit|
    face_cards.each { |card| deck << [suit, card] }
    2.upto(10) { |i| deck << [suit, i.to_s] }
  end
  deck
end

# DEAL CARD AND REMOVE FROM DECK
def deal_card(deck, player)
  card = deck.sample
  player << card
  deck.delete(card)
  card
end

# CARD VALUES & SUMMATION
def generate_card_values(hand)
  numbers = []
  hand.map do |card|
    if card[1].to_i.to_s != card[1]
      numbers << 10 if ['J', 'Q', 'K'].include?(card[1])
      numbers << 1 if card[1] == 'A'
    else
      numbers << card[1].to_i
    end
  end
  numbers
end

def sum(hand)
  limit = GAME_NUMBER + 1
  values = generate_card_values(hand)
  total = values.reduce(0) { |sum, val| sum + val }
  adjusted_ace_total = total + 10
  if values.include?(1) && adjusted_ace_total < limit
    return adjusted_ace_total
  end
  total
end

# INITIALIZE GAME AND DEAL FIRST HANDS
def init_dealer_cards(deck, dealer, colored_cards)
  cards = [deal_card(deck, dealer), deal_card(deck, dealer)]
  hidden_card = colorize_card(['NA', ''])
  first_card = colorize_card(cards[0])
  colored_cards << first_card.join
  colored_cards << hidden_card.join
end

def init_player_cards(deck, player, colored_cards)
  2.times do
    card = deal_card(deck, player)
    colored_card = colorize_card(card)
    colored_cards << colored_card.join
  end
end

def display_first_hands(colored_cards)
  arr = ['DEALER:', 'PLAYER:']
  colored_cards.each_with_index do |cards, i|
    puts colorize(arr[i], 6, 0)
    sleep(0.5)
    cards.each do |card|
      sleep(0.2)
      print card
    end
    2.times { puts "" }
  end
end

def init_game(deck, hands, colored_cards)
  init_dealer_cards(deck, hands[0], colored_cards[0])
  init_player_cards(deck, hands[1], colored_cards[1])
  display_first_hands(colored_cards)
  sleep(0.5)
  refresh_view(colored_cards, hands, 3)
end

def omit_second_card_from_total(hand)
  str_dealer = colorize('DEALER:', 6, 0)
  values = generate_card_values(hand)
  first_value = Rainbow(values[0]).red
  [str_dealer, first_value]
end

# COLORIZE CARD AND ADD SUIT ICONS
def colorize_card(card)
  suit = add_suit_icon(card[0])
  number = Rainbow(card[1]).black.bg(:white)
  [suit, number, " "]
end

def deal_and_colorize_card(deck, hand, colored_cards, str)
  if str == 'player'
    colorize("Dealing card to #{str}...", 1)
  else
    colorize("Dealing card to #{str}...", 0)
  end
  card = deal_card(deck, hand)
  colored_card = colorize_card(card)
  colored_cards << colored_card.join
  sleep(1)
end

def show_dealer(hands, colored_cards)
  prompt(Rainbow("Showing dealer card...").bright.red)
  sleep(2)
  hidden_card = colorize_card(['NA', '']).join
  colored_cards[0].map! do |card|
    if card == hidden_card
      colorize_card(hands[0][1]).join
    else
      card
    end
  end
  refresh_view(colored_cards, hands, 0)
end

# HANDLE PLAYER AND DEALER CARDS AFTER INITIAL HAND
def player_turn(deck, hands, colored_cards)
  answer = nil
  loop do
    break if game_number?(hands[1]) || busted?(hands[1])
    prompt('Would you like to (h)it or (s)tay?')
    answer = gets.chomp
    break if answer.downcase == 's'
    refresh_view(colored_cards, hands)
    deal_and_colorize_card(deck, hands[1], colored_cards[1], 'player')
    refresh_view(colored_cards, hands)
  end
  reveal_player_outcome(hands, colored_cards)
end

def dealer_turn(deck, hands, colored_cards)
  show_dealer(hands, colored_cards)
  loop do
    break if busted?(hands[1])
    sleep(1)
    break if sum(hands[0]) > GAME_NUMBER - 5 || busted?(hands[0])
    refresh_view(colored_cards, hands, 0)
    deal_and_colorize_card(deck, hands[0], colored_cards[0], 'dealer')
    sleep(1)
    refresh_view(colored_cards, hands, 0)
  end
  refresh_view(colored_cards, hands, 0)
end

def show_total(hands, turn)
  # DEALER
  str_dealer = colorize('DEALER:', 6, 0)
  dealer_total = colorize(sum(hands[0]), 0, 0)
  arr_dealer = [str_dealer, dealer_total]
  arr_hidden = omit_second_card_from_total(hands[0])
  # PLAYER
  str_player = colorize('PLAYER:', 6, 0)
  player_total = colorize(sum(hands[1]), 1, 0)
  arr_player = [str_player, player_total]
  return arr_player if turn == 1
  return arr_dealer if turn == 0
  return arr_hidden if turn == 3
end

def refresh_view(colored_cards, hands, turn = 3)
  clear
  player = show_total(hands, 1)
  dealer = show_total(hands, turn)
  play = [dealer, player]
  colored_cards.each_with_index do |cards, i|
    puts "#{play[i][0]} #{play[i][1]}"
    cards.each { |card| print card }
    2.times { puts '' }
  end
end

# DETECT/DISPLAY RESULTS
def game_number?(hand)
  if sum(hand) == GAME_NUMBER
    return true
  end
  false
end

def reveal_player_outcome(hands, colored_cards)
  refresh_view(colored_cards, hands)
  if game_number?(hands[1])
    num = NumbersInWords.in_words(GAME_NUMBER)
    colorize("#{num.titleize}!", 6)
  elsif busted?(hands[1])
    colorize('Bust!', 4)
  else
    colorize('You chose to stay!', 1)
  end
  sleep(1.5)
end

def busted?(hand)
  if sum(hand) > GAME_NUMBER
    sleep(0.5)
    return true
  end
  false
end

def detect_results(hands)
  totals = [sum(hands[0]), sum(hands[1])]
  if totals[1] > GAME_NUMBER
    :player_busted
  elsif totals[0] > GAME_NUMBER
    :dealer_busted
  elsif totals[1] > totals[0]
    :player
  elsif totals[0] > totals[1]
    :dealer
  else
    :tie
  end
end

def display_results(hands)
  result = detect_results(hands)
  case result
  when :player_busted
    colorize('You busted! Dealer wins!', 0)
  when :dealer_busted
    colorize('Dealer Busted! You win!', 3)
  when :player
    colorize('You win!', 3)
  when :dealer
    colorize('Dealer wins!', 0)
  when :tie
    colorize("It's a tie!", 2)
  end
end

def update_score(scores, hands)
  result = detect_results(hands)
  case result
  when :player_busted then scores[0] += 1
  when :dealer_busted then scores[1] += 1
  when :player then scores[1] += 1
  when :dealer then scores[0] += 1
  end
  prompt "Dealer: #{scores[0]}, Player: #{scores[1]}"
  sleep 1
end

def winning_score_reached?(scores)
  if scores[0] == 5
    colorize('Dealer is the grand winner!', 4)
    sleep 1
    return true
  elsif scores[1] == 5
    colorize('You are the grand winner!', 5)
    sleep 1
    return true
  end
  false
end

# ANIMATE INTRO & SET GAME_NUMBER
animate_intro
GAME_NUMBER = set_game_number
animate_game_number

# MAIN GAME LOOP
loop do
  scores = [0, 0]
  loop do
    deck = init_deck
    hands = [[], []]
    colored_cards = [[], []]
    clear
    init_game(deck, hands, colored_cards)

    player_turn(deck, hands, colored_cards)
    dealer_turn(deck, hands, colored_cards)
    display_results(hands)

    update_score(scores, hands)
    break if winning_score_reached?(scores)
    prompt('Press any key to continue')
    gets
  end
  prompt('Play again? (y/n)')
  answer = gets.chomp
  break if answer.downcase != 'y'
end

prompt('Hope you enjoyed the game! Goodbye!')
