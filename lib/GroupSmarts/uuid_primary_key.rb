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
    UUID_REGEXP = "[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}"
    UUID_RE = Regexp.new(UUID_REGEXP)

    def self.included(base)
      base.extend(ClassMethods)  
    end
    
    module ClassMethods
      def UUIDPrimaryKey(options = {})
        if options[:column]
          class_eval do
            set_primary_key options[:column]
          end #class_eval
        end #if
        class_eval do
          before_create :uuid! 
          include InstanceMethods
        end #class_eval
        # Ensures primary key is unique, but only makes the check when the PK is not nil at 
        # validation time (before before_create)
        validates_uniqueness_of(primary_key, :allow_nil => true)
        validate_on_create :validate_uuid
      end
    end
  
    module InstanceMethods
      # Assigns the UUID primary key from the local host's signature and a timestamp if not already set.
      def uuid!
        return self.id if self.id
        @uuid ||= ::UUID.timestamp_create
        self.uuid = @uuid.to_s
      end
      
      # Provides a restricted setter that does not require overriding attributes_protected_by_default
      def uuid=(u)
        raise "The UUID cannot be changed once set." if self.id
        write_attribute(self.class.primary_key, u)
      end
      
      # Returns UUID object corresponding to primary key.
      def UUID
        @uuid ||= ::UUID.parse(read_attribute(self.class.primary_key)) if read_attribute(self.class.primary_key) 
      end
      
      # Validate the UUID string representation
      def validate_uuid
        unless self.id.nil?
          begin
            errors.add(self.class.primary_key, "is invalid.") unless self.UUID.valid?
          rescue ArgumentError
            errors.add(self.class.primary_key, "can't be parsed")
          end
        end
      end #validate_on_create
    end #module
  end #module
end #module