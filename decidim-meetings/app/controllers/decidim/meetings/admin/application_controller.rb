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
        helper Decidim::ApplicationHelper
        helper_method :meetings, :meeting

        def meetings
          @meetings ||= Meeting.where(component: current_component).order("created_at DESC").page(params[:page]).per(15)
        end

        def meeting
          @meeting ||= meetings.find(params[:id]) if params[:id]
        end
      end
    end
  end
end
