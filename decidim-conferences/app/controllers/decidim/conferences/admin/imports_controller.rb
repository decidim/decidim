# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows importing things.
      # It is targeted for customizations for importing things that lives under
      # an conference.
      class ImportsController < Decidim::Admin::ImportsController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
