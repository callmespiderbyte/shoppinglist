# ------------------------------------------------------------------------
# METHODS
# ------------------------------------------------------------------------

require 'yaml'

@shopping_list = []
@updated_item_database = []
@items = YAML.load(File.read("ingredients.yml"))
@oldshoppinglist = YAML.load(File.read("oldshoppinglist.yml"))


def load_file
	@items.each do |list_item|
		@updated_item_database.push list_item
	end

	@oldshoppinglist.each do |old_item|
		@shopping_list.push old_item
	end
end

def run_shopping_list
	puts "Here's your list so far:"
	puts
	puts @shopping_list.join("\n")
	puts
	item = request_item
	while item != ""
		try_add_item(item)
		item = request_item
	end
end

def finish_shopping_list
	save_file
	save_for_export
end

def save_file
	File.open("ingredients.yml", "w") { |file| file.write(@updated_item_database.to_yaml) }
end

def save_for_export
	File.open("oldshoppinglist.yml", "w+") { |file| file.write(@shopping_list.to_yaml) }
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
		add_item(matched_items.first)
	else
		eliminate_dupes(item, matched_items)
	end
end

def find_item(item)
	@items.select do |ingredients|
		shop, test_item = ingredients.downcase.split(": ")
		test_item.start_with?(item.downcase)
	end
end

def add_item(item) #TODO: Fix. Not registering dupe?
	already_added = @shopping_list.any? do |ingredients|
		shop, test_item = ingredients.downcase.split(": ")
		test_item.start_with?(item.downcase)	
	end

	if already_added
		puts "You've already added that item!"
	else
		check_quantity_matched_item(item)
	end
end

def check_quantity_matched_item(item)
	puts "How much do you need? (units/grams/ml)"
	quantity = $stdin.gets.chomp
	
	case quantity 
	when "", "0"
		puts "Ok, I won't add '#{item}' to your list :)"
	else 
		add_to_shopping_list("#{item} (#{quantity})")
	end	

end

def add_to_shopping_list(item)
	@shopping_list.push(item)
	@shopping_list.sort!
end

def check_quantity_unmatched_item(item, shop)
	puts "Cool! Please tell me how much you need of '#{item}' - use units, grams, or millilitres:"
	quantity = $stdin.gets.chomp

	case quantity 
	when "", "0"
		puts "Ok, I won't add '#{item}' to your list :)"
	else 
		puts "Awesome, I've added '#{item} (#{quantity})' to your list :)"
		add_to_shopping_list("#{shop}: #{item} (#{quantity})")
		@updated_item_database.push "#{shop}: #{item}"
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

def run_addsave
	puts "-----------------"
	load_file 
	run_shopping_list
	finish_shopping_list
end

# ------------------------------------------------------------------------
# APP
# ------------------------------------------------------------------------


# load_file 
# run_shopping_list
# finish_shopping_list


# ------------------------------------------------------------------------
# SETUP
# ------------------------------------------------------------------------

#PASS When I open the app I see "what do you need?" and I can type an ingredient

#PASS When I input an ingredient, and it's in the "where to buy" list, it gets added to my shopping list with the shop I buy it from

#PASS When I input an ingredient and it's already in my shopping list, the app tells me it's already there, and asks me "What do you need?"

#PASS When I input an ingredient, and it's in the "where to buy" list but capitalised differently, it gets added to my shopping list with the shop I buy it from

#PASS When I input an ingredient, and it's NOT in the "where to buy" list, it asks me if I want to add it to the list anyway (without a shop)

#PASS When the app asks me if I want to add an ingredient to the list anyway, I can respond with "yes" and it gets added to my shopping list

#PASS When the app asks me if I want to add an ingredient to the list anyway, I can respond with "no" and it doesn't get added to my shopping list. I see "What do you need?" again

#PASS When I've added an ingredient to the shopping list, I see "What do you need?" again and can add another ingredient

#PASS When I'm done adding ingredients, I respond to "What do you need?" with "nothing" and see my shopping list as a list of alphabetised shops with the items i said i needed - "shop: item"


# data:
# 	"where to buy" list (static database)
# 		shop: item
# 		shop: item
# 		shop: item
# 		...
# 	shopping list ('built' database)
# 		shop: item
# 		shop: item
# 		shop: item
# 		... keyword_end
