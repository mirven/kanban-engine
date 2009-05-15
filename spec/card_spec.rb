require 'card'
require 'spec'
require 'spec/interop/test'

describe "Kanban Cards" do
  before do    
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

  end
  
  describe "Creating a Card with two queues with transitions between them" do
    before do
      
      class Card < ActiveRecord::Base
        include AASM
        include Kanban
        
        initial_queue :a        

        queue :a
        queue :b
        transition :a_to_b, :from => :a, :to => :b
        transition :b_to_a, :from => :b, :to => :a 
      end
      
      @card = Card.create! 
    end

    after do
      Object.instance_eval { remove_const("Card") }
    end

    it "should start with the inital queue state" do
      @card.state.should == "a"
    end
    
    it "should initially have no changes" do
      @card.changes.size.should == 0
    end
    
    describe "when moving from a to b" do
      before do
        @card.a_to_b(1)
      end
      
      it "should set the state to b" do
        @card.state.should == "b"
      end
      
      it "should record the change" do
        @card.changes.size.should == 1
      end
    end
  end

  describe "Defining a transition with a block" do
    before do
      
      class Card < ActiveRecord::Base
        include AASM
        include Kanban

        initial_queue :a

        attr_accessor :proc_run

        queue :a
        queue :b
        transition :a_to_b, :from => :a, :to => :b do |card, user| 
          card.proc_run = true 
        end
        transition :b_to_a, :from => :b, :to => :a 
      end
            
      @card = Card.create! 
      @card.a_to_b(1)
    end

    after do
      Object.instance_eval { remove_const("Card") }
    end

    it "should call the proc with the card and user" do
      @card.proc_run.should == true
    end
  end

end



