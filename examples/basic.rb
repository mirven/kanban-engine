require '../lib/card'

class Card < ActiveRecord::Base
  include Kanban
  
  kanban_queue :a
  kanban_queue :b
  kanban_transition :a_to_b, :from => :a, :to => :b
  kanban_transition :b_to_a, :from => :b, :to => :a 
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::ERROR
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
    create_table :cards do |t|
      t.string :state, :null => false
      t.timestamps
    end    
end

card = Card.create!

puts card.state
card.a_to_b(1)
puts card.state

