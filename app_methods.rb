require 'pg'

def conn
	PG.connect( dbname: 'mydb' )
end

def clear_table(table_name)
	conn.exec( "delete from #{table_name};" )
end

def setup_test_data
	# puts("<3")

	clear_table("item_database")
	conn.exec( "insert into item_database (id, item, shop) values (1, 'condoms', 'woolworths'), (2, 'coconut', 'woolworths'), (3, 'coconut milk', 'woolworths');" )
 
	clear_table("item_list")
	conn.exec( "insert into item_list (item_id, quantity) values (99, 1), (1, 1), (2, 1), (3, 1);" )
end

def get_input
	$stdin.gets.chomp
end

def look_in_list_for_item_id(item_id)
	conn.exec("select item_id from item_list where item_id = #{item_id}").to_a.any?
end

def add_to_shopping_list(item_id)
	puts "Please add a quantity:"
	quantity = get_input.to_i 

	conn.exec("insert into item_list (item_id, quantity) values (#{item_id}, #{quantity})")
end

def search_for_item(name)
	conn.exec("select id from item_database where item ilike '%#{name}%'")
end

def create_new_item(name)
	puts "Please add a shop:"
	shop = get_input
	conn.exec("insert into item_database (item, shop) values ('#{name}', '#{shop}')")
end

def find_quantity(item_id)
	result = conn.exec("select quantity from item_list where item_id = #{item_id}").to_a.last
	if result != nil
		result["quantity"]
	end
end

def format_item_id(result)
	result.to_a.first["id"]
end

def update_shopping_list(item_id)
	puts "Please add a new quantity:"
	quantity = get_input
	conn.exec("update item_list set quantity = #{quantity} where item_id = #{item_id}")
end

def add_to_or_update_shopping_list(item_id)
	already_added = look_in_list_for_item_id(item_id)

	if already_added
		puts "Do you want to update that item, or skip? [update / skip]"
		action = get_input
		if action == "update"
			update_shopping_list(item_id)
		end
	else
		add_to_shopping_list(item_id)
	end
end

def get_formatted_shopping_list
	conn.exec("select item_database.shop, item_database.item, item_list.quantity from item_database inner join item_list on item_database.id=item_list.item_id") do |list|
		list.to_a.map do |result|
	  	"#{result["shop"]}: #{result["item"]} (#{result["quantity"]})"
		end
	end
end

def view_list
	puts get_formatted_shopping_list
end

def send_to_imessage(list)
	message = list.join("\n")

	`open -a Messages`
	sleep 1.5
	`imessage --text "#{message}" --contacts "whoisdanieldavey@gmail.com"`
end

def send_list
	send_to_imessage(get_formatted_shopping_list)
end

def input_item
	puts "What item do you need?"
	input = get_input
	items_in_database = search_for_item(input)
	
	if items_in_database.count == 1 
		item_id = format_item_id(items_in_database)
		add_to_or_update_shopping_list(item_id)
		
	elsif items_in_database.count == 0 
			create_new_item(input)
			new_item = search_for_item(input)
			new_item_id = format_item_id(new_item)
			add_to_shopping_list(new_item_id)
		
	else "Too many matches, please try again"
	end
end

def remove_item
	puts "What do you want to remove from your list?"
	input = get_input
	already_added = get_formatted_shopping_list.map {|result| result.include?(input)}
	
	if already_added.one?(true)
		item = search_for_item(input)
		item_id = format_item_id(item)
		conn.exec("delete from item_list where item_id = #{item_id}")

	elsif already_added.none?(true)
		"That item is not in your list"

	else
		"Too many matches, please try again"
	end
end
	
		
