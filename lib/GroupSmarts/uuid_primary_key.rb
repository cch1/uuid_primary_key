#UUIDPrimaryKey
#==============
#
#Copyright 2006-2007, Chris Hapgood
#MIT License
#Derived from the works of several others, including Demetrio Nunes, Paul Dix and Lee Jensen.
#
#Requirements: UUIDTools GEM (gem install uuidtools)
#
#In any model class requiring a UUID PK, invoke UUIDPrimaryKey, optionally with 
#the name of the PK column in your database.  Example: 
#
#  class Person < ActiveRecord::Base
#    UUIDPrimaryKey
#  end
#  
#  class Place < ActiveRecord::Base
#    UUIDPrimaryKey :column => 'uuid'
#  end
# 
#Hints:
#  1. To override the value of the PK from the application, define an 
#  initialize method in your model like this:
#   class Person < ActiveRecord::Base
#     UUIDPrimaryKey :column => 'uuid'
#    
#     def initialize(params = nil)
#       super
#       self.id = params[:uuid] unless params[:uuid].nil?
#     end
#   end
#  
#  2. To define a reasonable colum using migrations, try this:
#   class AddPeople < ActiveRecord::Migration
#     def self.up
#       create_table :people, :id => false do |t|
#         t.column :uuid, :string, :limit => 36
#         t.column :firstnames, :string, :limit => 55
#         t.column :lastname, :string, :limit => 35
#         t.column :created_at, :timestamp
#         t.column :updated_at, :timestamp
#       end
#         execute("ALTER TABLE people ADD PRIMARY KEY(uuid)")
#     end
#   
#     def self.down
#       drop_table :people
#     end
#   end

require 'uuidtools'

module GroupSmarts
  module UUIDPrimaryKey #:nodoc:
    
    def self.included(base)
      base.extend(ClassMethods)  
    end
    
    module ClassMethods
      def UUIDPrimaryKey(options = {})
        class_eval do
          before_create :uuid_pk
          include InstanceMethods
        end #class_eval
        column = options[:column] || 'id'
        if options[:column]
          class_eval do
            set_primary_key options[:column]
            define_method(options[:column] + "_before_type_cast") do
              read_attribute_before_type_cast(self.class.primary_key)
            end
          end #class_eval
        end #if
        validates_uniqueness_of column
      end
    end
  end #module
  
  module InstanceMethods
    # Assigns the UUID primary key from the local host's signature and a timestamp.
    def uuid_pk(params = nil)
      self.id ||= UUID.timestamp_create.to_s
    end
    
    # The expectation here is that IF the controller provides the UUID 
    # attribute, then that attribute should be valid.  If no UUID is 
    # provided, then one will be assigned by the UUIDPrimaryKey module.
    def validate_on_create
      if !self.uuid.nil?
        begin
          errors.add("uuid", "is invalid.") unless UUID.parse(self.uuid).valid?
        rescue ArgumentError
          errors.add("uuid", "can't be parsed")
        end
      end
    end
  end #module
end #module