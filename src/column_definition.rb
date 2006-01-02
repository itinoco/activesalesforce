require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/abstract/schema_definitions'

module ActiveRecord  
  module ConnectionAdapters
    class SalesforceColumn < Column
      attr_reader :label, :updateable, :reference_to
      
      def initialize(field)
        @name = field["name"]
        @type = get_type(field["type"])
        @limit = field["length"]
        @label = field["label"]
        
        @text = [:string, :text].include? @type
        @number = [:float, :integer].include? @type
        
        @updateable = field["updateable"]
        
        if field["type"] =~ /reference/i
          @reference_to = field["referenceTo"]
        end
      end
      
      def get_type(field_type)
          case field_type
            when /int/i
              :integer
            when /currency|percent/i
              :float
            when /datetime/i
              :datetime
            when /date/i
              :date
            when /id|string|textarea/i
              :text
            when /phone|fax|email|url/i
              :string
            when /blob|binary/i
              :binary
            when /boolean/i
              :boolean
            when /reference/i
              :text
          end
      end
      
      def human_name
        @label
      end
    end
  end
end    