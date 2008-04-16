# Adds support for UUID columns in Migrations.  Typical Usage:
#
#   change_column :medium_playlists, :medium_id, :uuid
#
# To create a UUID primary key, use this syntax:
#
#   class AddAttachments < ActiveRecord::Migration
#     def self.up
#       create_table "attachments", :id => false, :force => true do |t|
#         t.column :uuid, :uuid_pk, :default => '00000000-0000-0000-0000-000000000000'
#       end
#     end
#   end 


# This patch to the MySQL Adapter adds support for 36-byte string-based UUID columns.  The columns are forced to
# the ASCII character set to ensure that the these frequently-indexed columns are only 36 bytes long (instead of 
# triple that length with UTF-8).
class ActiveRecord::ConnectionAdapters::MysqlAdapter
  def native_database_types_with_uuid
    returning native_database_types_without_uuid do |h|
      h[:uuid_pk] = {:name => "char(36) CHARACTER SET ascii COLLATE ascii_general_ci PRIMARY KEY"}
      h[:uuid] = {:name => "CHAR(36) CHARACTER SET ascii COLLATE ascii_general_ci"}
    end
  end
  alias_method_chain :native_database_types, :uuid
end