require 'GroupSmarts/uuid_primary_key'
ActiveRecord::Base.send(:include, GroupSmarts::UUIDPrimaryKey)