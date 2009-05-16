require '../lib/card'

class Card < ActiveRecord::Base
end

class PipelineCard < Card
  include Kanban
  
  kanban_initial_queue :new

  kanban_queue :new
  kanban_queue :ready_for_ux_design
  kanban_queue :ux_design
  kanban_queue :ready_for_development
  kanban_queue :development
  kanban_queue :ready_for_testing
  kanban_queue :testing
  kanban_queue :done_testing
  kanban_queue :accepted
  kanban_queue :released  
  kanban_queue :deferred
  kanban_queue :suspended    
  
  kanban_transition :new_to_ready_for_ux_design, :to => :ready_for_ux_design, :from => :new 
  kanban_transition :new_to_ready_for_development, :to => :ready_for_development, :from => :new
  kanban_transition :new_to_ready_for_testing, :to => :ready_for_testing, :from => :new
  kanban_transition :suspend, :to => :suspended, :from => [ :new, :ready_for_ux_design, :ux_design, :ready_for_development, :development, :done_development, :ready_for_testing, :testing, :done_testing, :accepted ]    
  kanban_transition :defer, :to => :deferred, :from => [ :new, :ready_for_ux_design, :ux_design, :ready_for_development, :development, :done_development, :ready_for_testing, :testing, :done_testing, :accepted ]  
  kanban_transition :back_to_new, :to => :new, :from => [ :ready_for_ux_design, :ux_design, :ready_for_development, :development, :ready_for_testing, :testing, :done_testing, :accepted, :deferred, :suspended ]  
  kanban_transition :start_ux_design, :to => :ux_design, :from => :ready_for_ux_design
  kanban_transition :finish_ux_design, :to => :ready_for_development, :from => :ux_design      
  kanban_transition :start_development, :to => :development, :from => :ready_for_development
  kanban_transition :finish_development, :to => :ready_for_testing, :from => :development
  kanban_transition :start_testing, :to => :testing, :from => :ready_for_testing
  kanban_transition :finish_testing, :to => :done_testing, :from => :testing
  kanban_transition :accept, :to => :accepted, :from => :done_testing
  kanban_transition :reject, :to => :new, :from => :done_testing
  kanban_transition :release, :to => :released, :from => :accepted
end

class FeatureCard < PipelineCard
end

class ReworkCard < PipelineCard
end

class ChoreCard < Card
  include Kanban

  kanban_queue :opened
  kanban_queue :accepted
  kanban_queue :closed
  kanban_transition :accept, :from => :opened, :to => :accepted
  kanban_transition :closed, :from => :accepted, :to => :closed 
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::ERROR
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 1) do
    create_table :cards do |t|
      t.string :state, :null => false
      t.string :type, :null => false
      t.string :name, :null => false
      t.string :description, :null => false
      t.timestamps
    end    
end

card = FeatureCard.create! :name => "card name", :description => "stuff"

puts card.state
card.new_to_ready_for_ux_design(1)
puts card.state

