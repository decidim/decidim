# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This module, when injected into a controller, ensures there's a
      # Conference available and deducts it from the context.
      module ConferenceContext
        def self.extended(base)
          base.class_eval do
            include Concerns::ConferenceAdmin

            alias_method :current_conference, :current_participatory_space
          end
        end
      end
    end
  end
end
