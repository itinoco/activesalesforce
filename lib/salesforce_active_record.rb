require 'xsd/datatypes'
require 'soap/soap'

require File.dirname(__FILE__) + '/sobject_attributes'


module ActiveRecord
  # Active Records will automatically record creation and/or update timestamps of database objects
  # if fields of the names created_at/created_on or updated_at/updated_on are present. This module is
  # automatically included, so you don't need to do that manually.
  #
  # This behavior can be turned off by setting <tt>ActiveRecord::Base.record_timestamps = false</tt>.
  # This behavior can use GMT by setting <tt>ActiveRecord::Base.timestamps_gmt = true</tt>
  module SalesforceRecord 
    include SOAP, XSD

    NS1 = 'urn:partner.soap.sforce.com'
    NS2 = "urn:sobject.partner.soap.sforce.com"    

    def self.append_features(base) # :nodoc:
      super

      base.class_eval do
        alias_method :create, :create_with_sforce_api
        alias_method :update, :update_with_sforce_api
      end
    end    
      
    def create_with_sforce_api
      return if not @attributes.changed?
      puts "create_with_sforce_api creating #{self.class}"
      connection.create(create_command("create"))      
    end

    def update_with_sforce_api
      return if not @attributes.changed?
      puts "update_with_sforce_api updating #{self.class}('#{self.Id}')"
      connection.update(create_command("update"))
    end
    
    def create_command(command)
      fields = @attributes.changed_fields
            
      element = SOAPElement.new(QName.new(NS1, command))

      sobj = SOAPElement.new(QName.new(NS1, 'sObjects'))
      sobj.add(SOAPElement.new(QName.new(NS2, "type"), self.class.name))
      sobj.add(SOAPElement.new(QName.new(NS2, 'Id'),  self.Id)) if self.Id
      
      # now add any changed fields
      fields.each do |fieldName|
        value = @attributes[fieldName]
        if value
          value = value.xmlschema(3) if value.is_a?(Time)
  
          value = value.to_s if value.is_a?(Date) or value.is_a?(Fixnum)
          
          fieldElement = SOAPElement.new(fieldName, value)
          
          sobj.add(fieldElement)
        end
      end

      element.add(sobj)
      
      element
    end

  end 
  
  class Base
    set_inheritance_column nil
    lock_optimistically = false
    record_timestamps = false
    default_timezone = :utc
    
    def after_initialize() 
      if not @attributes.is_a?(Salesforce::SObjectAttributes)
        # Insure that SObjectAttributes is always used for our atttributes
        originalAttributes = @attributes 
        
        @attributes = Salesforce::SObjectAttributes.new(connection.columns_map(self.class.table_name))
        
        originalAttributes.each { |name, value| self[name] = value }
      end
    end
  
    def self.table_name
      class_name_of_active_record_descendant(self)
    end
    
    def self.primary_key
      "Id"
    end
  
    def self.construct_finder_sql(options)
      soql = "SELECT #{column_names.join(', ')} FROM #{table_name} "
      add_conditions!(soql, options[:conditions])
      soql
    end
    
    def self.construct_conditions_from_arguments(attribute_names, arguments)
      conditions = []
      attribute_names.each_with_index { |name, idx| conditions << "#{name} #{attribute_condition(arguments[idx])} " }
      [ conditions.join(" AND "), *arguments[0...attribute_names.length] ]
    end
    
    def self.count(conditions = nil, joins = nil)
        soql  = "SELECT Id FROM #{table_name} "
        add_conditions!(soql, conditions)
        
        count_by_sql(soql)
    end
    
    def self.count_by_sql(soql)
      connection.select_all(soql, "#{name} Count").length
    end  

  end
end