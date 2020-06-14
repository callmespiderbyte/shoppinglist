require './app_methods.rb'
require 'rainbow'

# menu = ["input", "remove", "view list", "clear list", "send list", "exit"]
setup_test_data

require 'sinatra'


get '/list' do
  get_formatted_shopping_list.join(", ")
end


get '/add' do
	name = params['name']
	shop = params['shop']
	conn.exec("insert into item_database (item, shop) values ('#{name}', '#{shop}')")
	new_item = search_for_item(name)
	new_item_id = format_item_id(new_item)
	quantity = params['quantity']
	conn.exec("insert into item_list (item_id, quantity) values (#{new_item_id}, #{quantity})")
end

