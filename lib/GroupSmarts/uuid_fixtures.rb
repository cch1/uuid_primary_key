# This patch to the Rails Fixtures class will add support for 
# generating a known constant UUID from a label, a la foxy fixtures.
# In your test_helper.rb file, require this file:
# require 'GroupSmarts/uuid_fixtures'  
require 'uuidtools'
raise "Fixtures not yet loaded, but loading now will expose a bug (RoR:#10379) in reloading Test::Unit::TestCase." unless Object.const_defined?("Fixtures")
class Fixtures
  def self.identify_with_uuid_option(label, uuid = false)
    number = self.identify_without_uuid_option(label)
    uuid ? UUID.new(number, 0, 16384, 128, 0, [0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc]).to_s : number
  end
  class << self
    alias_method_chain :identify, :uuid_option
  end
end