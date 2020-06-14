require './app_methods.rb'
require 'rainbow'

def print_menu
	puts
	puts "What would you like to do?"

	menu = ["input", "remove", "view list", "clear list", "send list", "exit"]

	new_menu = menu.map do |item|
		Rainbow(item[0]).bold.blue + item[1..-1]
	end
	
	print new_menu.join(" / ")
	print " >> "
end

print_menu
input = get_input

while input != "exit"

	case input
		when /^i/
			input_item
		when /^r/
			remove_item
			puts "I have removed that item from your shopping list!"
		when /^v/
			view_list
		when /^c/
			clear_table("item_list")
			puts "I've cleared your list!"
		when /^s/
			send_list
			puts "I have sent a message to Dan!"
	end
		
	print_menu
	input = get_input

end