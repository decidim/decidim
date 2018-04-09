# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :meetings, :meeting

        include NeedsPermission

        private

        def permission_class_chain
          [
            Decidim::Accountability::Permissions,
            current_participatory_space.manifest.permissions_class,
            Decidim::Admin::Permissions
          ]
        end

        def permission_scope
          :admin
        end

        def meetings
          @meetings ||= Meeting.where(component: current_component).page(params[:page]).per(15)
        end

        def meeting
          @meeting ||= meetings.find(params[:id])
        end
      end
    end
  end
end
