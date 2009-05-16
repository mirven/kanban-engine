require 'rubygems'
require 'aasm'
require 'activerecord'

module Kanban
  def self.included(base) 
    base.extend Kanban::ClassMethods
    
    base.class_eval do
      include AASM
      
      # if we are using ActiveRecord then we need to set the column
      hierarchy = ancestors.map {|klass| klass.to_s}      
      if hierarchy.include?("ActiveRecord::Base")
        aasm_column :state    
      end
    end
  end

  module ClassMethods
    def kanban_initial_queue(queue)
      aasm_initial_state queue
    end

    def kanban_queue(state_name)
      aasm_state state_name
    end

    def kanban_transition(event_name, transition_definitions, &blk)
      aasm_event event_name do
        transitions transition_definitions.merge(:on_transition => blk)
      end

      class_eval do
        orignal_event = instance_method(event_name)

        define_method event_name.to_sym do |user|
          original_state = state
          success = orignal_event.bind(self).call(nil, user)
          # if success 
          #   CardChange.create! :card => self, :user => user, :original_state => original_state, :changed_state => state, :change_description => "blah"
          # end
          return success
        end
      end    
    end    
  end  
end
