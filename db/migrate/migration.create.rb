class setupDB < ActiveRecord::Migration
  def self.up
  	create_table :users do |t|
  		t.string :username, :null => false,
  		t.string :password, :null => false,
  		t.integer :area_id,
  		t.integer :room_id
  	end

  	create_table :areas do |t|
  		t.string :name, :null => false
  	end

  	create_table :rooms do |t|
  		t.integer :area_id,
  		t.text :exits,
  		t.string :title,
  		t.text :description
  	end

  	create_table :mobs do |t|
  		t.string :name, :null => false,
  		t.string :area_id, :null => false,
  		t.string :starting_room_id, :null => false,
  		t.string :short_description, :null => false,
  		t.string :long_description
  	end

  end

  def self.down
  	drop_table :users
  	drop_table :areas
  	drop_table :rooms
  	drop_table :mobs
  end
end