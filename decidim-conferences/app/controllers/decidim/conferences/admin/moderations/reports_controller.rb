# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      module Moderations
        # This controller allows admins to manage moderation reports in an conference.
        class ReportsController < Decidim::Admin::Moderations::ReportsController
          include Concerns::ConferenceAdmin
        end
      end
    end
  end
end
