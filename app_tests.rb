require './app.rb'
require 'rainbow'

# ====================================

def get_input
	input = @input.is_a?(Array) ? @input.shift : @input
	puts ">> Got input #{input}"
	input
end

def test_get_input_stub
	start_tests(__method__)
	@input = ["hello", "there"]
	check(get_input == "hello")
	check(get_input == "there")
	check(get_input == nil)
end

def run_tests
	setup_test_data
	test_get_input_stub
	test_look_in_list_for_item_id
	test_add_to_shopping_list
	test_search_for_item
	test_create_new_item
	test_find_quantity
	test_update_shopping_list
	test_add_to_or_update_shopping_list
	test_get_formatted_shopping_list
	test_format_item_id
	test_input_item
	test_remove_item
	test_clear_table
end

def start_tests(method_name)
	setup_test_data
	puts
	puts Rainbow("TEST: #{method_name.upcase}").bold
	@test_number = 0
end

def check(condition)
	@test_number += 1

	print "test #{@test_number}:"
	if condition
		puts Rainbow("win").bold.green
	else
		puts Rainbow("fail").bold.red
	end
end

def test_look_in_list_for_item_id
	start_tests(__method__)
	check(look_in_list_for_item_id(99))
	check(look_in_list_for_item_id(1234) == false)
end

def test_add_to_shopping_list
	start_tests(__method__)
	check(look_in_list_for_item_id(1111) == false)

	@input = "2"
	add_to_shopping_list(1111)

	check(look_in_list_for_item_id(1111) == true)
end

def test_search_for_item
	start_tests(__method__)
	check(search_for_item("condoms").count == 1)
	check(search_for_item("thing").count == 0)
	check(search_for_item("coconut").count > 1)
	check(search_for_item("mil").count == 1)
end

def test_create_new_item
	start_tests(__method__)
	check(search_for_item("thing").count == 0)
	
	@input = "pnp"
	create_new_item("thing")

	check(search_for_item("thing").count == 1)
end

def test_find_quantity
	start_tests(__method__)
	check(find_quantity(99) == "1")
	check(find_quantity(10) == nil)
end

def test_update_shopping_list
	start_tests(__method__)
	check(find_quantity(99) == "1")

	@input = 2
	update_shopping_list(99)

	check(find_quantity(99) == "2")
end

def test_add_to_or_update_shopping_list
	start_tests(__method__)
	
	@input = ["update", "3"]
	check(find_quantity(99) == "1")
	add_to_or_update_shopping_list(99)
	check(find_quantity(99) == "3")

	@input = "skip"
	check(find_quantity(1) == "1")
	add_to_or_update_shopping_list(1)
	check(find_quantity(1) == "1")

	@input = "2"
	check(look_in_list_for_item_id(1234) == false)
	add_to_or_update_shopping_list(1234)
	check(look_in_list_for_item_id(1234) == true)
	check(find_quantity(1234) == "2")
end

def test_get_formatted_shopping_list
	start_tests(__method__)

	check(get_formatted_shopping_list == [
		"woolworths: condoms (1)",
		"woolworths: coconut (1)",
		"woolworths: coconut milk (1)"
	])
end

def test_format_item_id
	start_tests(__method__)

	check(format_item_id(search_for_item("condoms")) == "1")
end

def test_input_item
	start_tests(__method__)

	@input = ["thing", "thing shop", "1"]
	input_item
	check(search_for_item("thing").count == 1)
	check(get_formatted_shopping_list.include?("thing shop: thing (1)"))

	@input = ["condoms", "update", "5"]	
	input_item
	check(find_quantity(1) == "5")

	@input = "coconut"
	check(input_item == "Too many matches, please try again")
end

def test_remove_item
	start_tests(__method__)

	@input = "thing"
	check(remove_item == "That item is not in your list")

	@input = "condoms"

	check(get_formatted_shopping_list.any?{|string| string.include?("condoms") })
	remove_item
	check(!get_formatted_shopping_list.any?{|string| string.include?("condoms") })

	@input = "coconut"
	check(remove_item == "Too many matches, please try again")
	check(get_formatted_shopping_list.any?{|string| string.include?("coconut") })
end

def test_clear_table
	start_tests(__method__)
	check(search_for_item("condoms").count == 1)
	clear_table("item_database")
	check(search_for_item("condoms").count == 0)

	check(look_in_list_for_item_id(99) == true)
  	clear_table("item_list")
	check(look_in_list_for_item_id(99) == false)
end

# ====================================

run_tests




