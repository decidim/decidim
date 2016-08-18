require 'decidim/core/engine'
require 'devise'

module Decidim
  @config = OpenStruct.new

  def self.setup
    yield(@config)
  end

  def self.config
    @config
  end
end
