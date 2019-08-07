# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows exporting things.
      # It is targeted for customizations for exporting things that lives under
      # an conference.
      class ExportsController < Decidim::Admin::ExportsController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
