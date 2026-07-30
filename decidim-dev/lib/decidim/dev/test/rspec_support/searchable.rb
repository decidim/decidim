# frozen_string_literal: true

module Decidim
  # Attribute that can be handled to enable or disable search behavior for speed up of the specs
  mattr_accessor :skip_indexing, default: false
end

RSpec.configure do |config|
  config.around(:each, :with_search) do |example|
    Decidim.skip_indexing = false
    example.run
    Decidim.skip_indexing = true
  end
end
