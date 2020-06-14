require 'pg'

@conn = PG.connect( dbname: 'mydb' )

def connect_list
	@conn.exec( "SELECT * FROM things" ) do |result|
	  @things = result.to_a.map do |thing|
	  	"#{thing["shop"]}: #{thing["item"]} (#{thing["quantity"]})"
	  end
	end
end

def format_list
	connect_list
	puts "Here's your list:"
	puts "------------------------"
	puts @things
	puts "------------------------"
	puts
end

def request_shop
	puts
	puts "Where do you buy that?"
	puts
	return $stdin.gets.chomp
end

def add_item(item, shop)
	@conn.exec("insert into things (shop, item, quantity) values ('#{shop}', '#{item}', 1)")
end

def get_quantity(item)
	result = @conn.exec("select quantity from things where item = '#{item}'").to_a[0]
	if result
	  return result["quantity"].to_i
	end
end

def update_item(item)
	add_one = get_quantity(item) + 1
	@conn.exec("update things set quantity = #{add_one} where item = '#{item}'")
end

def try_add_item(item)

	if get_quantity(item)
		update_item(item)
	else
		shop = request_shop
			if shop == ""
		 		end_program
		 	else add_item(item, shop)
			end
	end
end

def get_input
	puts "Whatcha need?"
	puts "Type an item you need, type 'clear' to clear the list, or hit 'enter' to end the program!"
	puts
	return $stdin.gets.chomp
end

def clear_list
 @conn.exec("delete from things")
end

def format_cleared_list
	clear_list
	puts "Ok! I've cleared your shopping list :)"
	puts
end

def end_program
	puts "Bye bye!"
	puts
end

def run
	connect_list
	format_list
	
	item = get_input 

	case item
	when ""
		end_program
	when "clear"
	 	display_cleared_list
	else
		try_add_item(item)
	end

end

run
format_list