# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:example, without_authorizations: true) do |example|
    begin
      previous_handlers = Decidim.authorization_handlers
      Decidim.authorization_handlers = []

      example.run
    ensure
      Decidim.authorization_handlers = previous_handlers
    end
  end
end
