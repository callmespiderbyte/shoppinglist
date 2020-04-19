
require 'yaml'
require './shoppinglist_methods'

puts "Do you want to add to your shopping list, or do you want to finish it and send it?"
puts "Type 'add' or 'finish':"

input = $stdin.gets.chomp.downcase

while input != "add" && input != "finish"

	puts "Sorry, I didn't recognise that... Could you try again?"
	
	input = $stdin.gets.chomp.downcase

end

if input == "add"
	run_addsave
else 
	run_sendclear
end

