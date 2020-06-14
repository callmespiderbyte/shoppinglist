# ========================================================================
# CALLS and VARIABLES:
# ========================================================================

require 'yaml'

@shopping_list = []
@updated_item_database = []
@item_database = YAML.load(File.read("item_database_restructured.yml"))
@previous_shopping_list = YAML.load(File.read("currentshoppinglist.yml"))



# ========================================================================
# ALL METHODS:
# ========================================================================

# ------------------------------------------------------------------------
# SETUP (1/3)
# ------------------------------------------------------------------------

def run_addsave
	puts "-----------------"🐝
	load_file 
	run_shopping_list
	finish_addsave
end

def run_sendclear
	puts "-----------------"
	load_file 
	run_shopping_list
	finish_sendclear
end

def load_file
	@item_database.each do |list_item|
		@updated_item_database.push list_item
	end

	@previous_shopping_list.each do |old_item|
		@shopping_list.push old_item
	end
end



# ------------------------------------------------------------------------
# MAIN APP (2/3)
# ------------------------------------------------------------------------


# TODO
# Show list
# Remove item
# Add more to existing shopping list item


def run_shopping_list
	puts "Here's your list so far:"
	puts
	puts format_list(@shopping_list)
	puts
	item = request_item
	while item != ""
		try_add_item(item)
		item = request_item
	end
end

def request_item
	puts "What else do you need?"
	item = $stdin.gets.chomp
end

def try_add_item(item)
	matched_items = find_item(item)

	case matched_items.count
	when 0
		try_add_unmatched_item(item)
	when 1
		add_item(item)
	else
		eliminate_dupes(item, matched_items)
	end
end

def find_item(item)
	@item_database.select do |list_item|
		list_item[:item].downcase.start_with?(item.downcase)
	end
end

def find_new_shop(item)
	found_items = @item_database.detect do |list_item|
		list_item[:item].downcase.start_with?(item.downcase)
	end

  shop = found_items.first[:shop]
  shop
end

def add_item(item)
	already_added = @shopping_list.any? do |list_item|
		list_item[:item].downcase.start_with?(item.downcase)
	end

	if already_added
		puts "You've already added that item!"
	else
		check_quantity_matched_item(item)
	end
end

def check_quantity_matched_item(item)
	puts "How much do you need? (units/grams/ml/etc.)"
	quantity = $stdin.gets.chomp
	
	case quantity 
	when "", "0"
		puts "Ok, I won't add '#{item}' to your list :)"
	else 
		add_to_shopping_list(item, quantity)
	end	

end

def find_shop(item)
  found_items = find_item(item)
  shop = found_items.first[:shop]
end

def find_new_shop(item, quantity)
	found_items = @updated_item_database.select do |list_item|
		list_item[:item].downcase.start_with?(item.downcase)
	end

  shop = found_items.first[:shop]
end

def add_to_shopping_list_from_new_shop(shop, item, quantity)
	@shopping_list.push({
		shop: shop,
		item: item,
		quantity: quantity
	})
end

def add_to_shopping_list(item, quantity)
	@shopping_list.push({
		shop: find_shop(item),
		item: item,
		quantity: quantity
	})
end

def check_quantity_unmatched_item(item, shop)
	puts "Cool! Please tell me how much you need of '#{item}' - use units, grams, millilitres, or an equivalent measurement:"
	quantity = $stdin.gets.chomp

	case quantity 
	when "", "0"
		puts "Ok, I won't add '#{item}' to your list :)"
	else 
		@updated_item_database.push({ shop: shop, item: item })
		find_new_shop(item, quantity)
		add_to_shopping_list_from_new_shop(shop, item, quantity)		
		puts "Awesome, I've added '#{item} (#{quantity})' to your list :)"
	end

end

def try_add_unmatched_item(item)
	puts "Couldn't find '#{item}'... Where do you buy '#{item}'? (OR: hit enter to skip and try again)"
	shop = $stdin.gets.chomp
	check_quantity_unmatched_item(item, shop) if shop != ""
end

def eliminate_dupes(item, matches)
	ingredient_list = matches.map do |ingredients|
			ingredients.split(": ").last
	end

	puts "I found '#{item}' in #{matches.count} other items: #{ingredient_list.join(', ')}"
	puts "Please write which one of those you'd like to add to your list:"
	
	item = $stdin.gets.chomp

	try_add_item(item)
end

def format_row(item)
	"#{item[:shop]}: #{item[:item]} (#{item[:quantity]})"
end

def format_list(list)
	list.map do |item|
		format_row(item)
	end.sort.join("\n")
end




# ------------------------------------------------------------------------
# TIDY UP (3/3)
# ------------------------------------------------------------------------

def finish_addsave
	save_file
	save_for_export
end

def finish_sendclear
	save_file
	send_shopping_list_as_imessage
	wipe_oldshoppinglist
end

def save_file
	File.open("item_database_restructured.yml", "w") { |file| file.write(@updated_item_database.to_yaml) }
end

def save_for_export
	File.open("currentshoppinglist.yml", "w+") { |file| file.write(@shopping_list.to_yaml) }
end

def send_shopping_list_as_imessage
	message = format_list(@shopping_list)
	`open -a Messages`
	sleep 1.5
	`imessage --text "#{message}" --contacts "whoisdanieldavey@gmail.com"`
	puts "Cool - I've sent you a message! :D"
end

def wipe_oldshoppinglist
	@shopping_list.clear
	File.open("currentshoppinglist.yml", "w") { |file| file.write(@shopping_list.to_yaml) }
end

