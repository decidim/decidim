# frozen_string_literal: true

module Decidim
  # This module contains all the logic needed for a controller to render a participatory space
  # public layout.
  #
  module ParticipatorySpaceContext
    extend ActiveSupport::Concern

    class_methods do
      # Public: Called on a controller, it sets up all the surrounding methods to render a
      # participatory space's template. It expects the method `current_participatory_space` to be
      # defined, from which it will extract the participatory manifest.
      #
      # options - A hash used to modify the behavior of the layout. :only: - An array of actions on
      #           which the layout will be applied.
      #
      # Returns nothing.
      def participatory_space_layout(options = {})
        layout :layout, options
        before_action :authorize_participatory_space, options
      end
    end

    included do
      include Decidim::NeedsOrganization

      helper ParticipatorySpaceHelpers, IconHelper
      helper_method :current_participatory_space
      helper_method :current_participatory_space_manifest
      helper_method :current_participatory_space_context

      delegate :manifest, to: :current_participatory_space, prefix: true
    end

    private

    def current_participatory_space_context
      :public
    end

    def current_participatory_space
      raise NotImplementedError
    end

    def authorize_participatory_space
      enforce_permission_to :read, :participatory_space, current_participatory_space: current_participatory_space
    end

    def layout
      current_participatory_space_manifest.context(current_participatory_space_context).layout
    end

    # Method for current user can visit the space (assembly or proces)
    def current_user_can_visit_space?
      (current_participatory_space.try(:private_space?) &&
       current_participatory_space.users.include?(current_user)) ||
        !current_participatory_space.try(:private_space?) ||
        (current_participatory_space.try(:private_space?) &&
        current_participatory_space.try(:is_transparent?))
    end

    def check_current_user_can_visit_space
      return if current_user_can_visit_space?
      flash[:alert] = I18n.t("participatory_space_private_users.not_allowed", scope: "decidim")
      redirect_to action: "index"
    end
  end
end
