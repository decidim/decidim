# frozen_string_literal: true

module Decidim
  module Dev
    class AdminEngine < Rails::Engine
      engine_name "dummy_admin"

      routes do
        resources :dummy_resources do
          resources :nested_dummy_resources
        end

        root to: proc { [200, {}, ["DUMMY ADMIN ENGINE"]] }
      end
    end
  end
end
