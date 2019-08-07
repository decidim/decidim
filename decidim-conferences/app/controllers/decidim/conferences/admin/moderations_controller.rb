# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows admins to manage moderations in an conference.
      class ModerationsController < Decidim::Admin::ModerationsController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
