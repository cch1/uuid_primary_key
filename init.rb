require 'GroupSmarts/uuid_primary_key'
require 'GroupSmarts/uuid_migrations'
ActiveRecord::Base.send(:include, GroupSmarts::UUIDPrimaryKey)