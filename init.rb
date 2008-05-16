require 'GroupSmarts/uuid_primary_key'
require 'GroupSmarts/uuid_migrations' if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
#require 'GroupSmarts/uuid_fixtures'
ActiveRecord::Base.send(:include, GroupSmarts::UUIDPrimaryKey)