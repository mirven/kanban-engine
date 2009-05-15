require 'rubygems'
require 'aasm'
require 'activerecord'

module Kanban
  def self.included(base) 
    base.extend Kanban::ClassMethods
    
    base.aasm_column :state
    
  end

  module ClassMethods
    def initial_queue(queue)
      aasm_initial_state queue
    end

    def queue(state_name)
      aasm_state state_name
    end

    def transition(event_name, transition_definitions, &blk)
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
