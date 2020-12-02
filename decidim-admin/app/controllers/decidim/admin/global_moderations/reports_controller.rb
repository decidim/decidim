# frozen_string_literal: true

module Decidim
  module Admin
    module GlobalModerations
      # This controller allows admins to manage reports in a moderation.
      class ReportsController < Decidim::Admin::Moderations::ReportsController
        layout "decidim/admin/global_moderations"

        include Decidim::Admin::GlobalModerationContext

        def moderation
          @moderation ||= moderations_for_user.find(params[:moderation_id])
        end
      end
    end
  end
end
