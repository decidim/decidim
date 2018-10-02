# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing the Conference' Component
      # permissions in the admin panel.
      #
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
