# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows sharing unpublished things.
      # It is targeted for customizations for sharing unpublished things that lives under
      # an conference.
      class ShareTokensController < Decidim::Admin::ShareTokensController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
