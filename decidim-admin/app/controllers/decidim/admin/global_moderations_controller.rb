# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admin users to manage all moderations from the
    # participatory spaces they have access to.
    class GlobalModerationsController < Decidim::Admin::ModerationsController
      layout "decidim/admin/global_moderations"

      include Decidim::Admin::GlobalModerationContext

      # Private: This method is used by the `Filterable` concern as the base query
      # without applying filtering and/or sorting options.
      def collection
        @collection ||=
          if params[:hidden]
            moderations_for_user.where.not(hidden_at: nil)
          else
            moderations_for_user.where(hidden_at: nil)
          end
      end

      # Private: fins the reportable of the specific moderation the user is
      # trying to manage.
      #
      # Returns a resource implementing the `Decidim::Reportable` concern.
      def reportable
        @reportable ||= moderations_for_user.find(params[:id]).reportable
      end
    end
  end
end
