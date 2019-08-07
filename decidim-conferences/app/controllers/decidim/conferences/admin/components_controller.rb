# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing the Conference' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ComponentsController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
