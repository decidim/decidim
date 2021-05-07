# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :caching) do |example|
    caching = ActionController::Base.perform_caching
    cache_store = ActionController::Base.cache_store
    ActionController::Base.perform_caching = true
    ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new

    example.run

    ActionController::Base.perform_caching = caching
    ActionController::Base.cache_store = cache_store
  end
end
