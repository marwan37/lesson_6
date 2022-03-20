
```ruby
require 'pry'
puts 'Please pick an option: 1 or 2'
user_input = gets.chomp
binding.pry #stops program execution at this point
if user_input == '1'
  puts "You picked option 1"
elsif user_input == '2'
  puts "You picked option 2"
else
  puts "Invalid option!!"
end


loop do
  p eval gets #simulates irb environment
end
```

## pry
# cd allows you to change scope
pry: arr = [1, 2 3]
pry: cd arr
 pry(#<Array>):1> first
=> 1
 pry(#<Array>):1> last
=> 3

# ls allows you to access all methods available for that class

# whereami
takes you back to the point where you were in your program

# whereami 15
shows 15 lines of code above and below where you were in the program

# exit
exits one iteration / binding.pry

# exit!
exits whole program

## pry-byebug
# next
goes to next condition if condition not met (if -> elsif)
goes to next line of code / iteration

# continue
skips to next iteration

# step
steps into method being called

