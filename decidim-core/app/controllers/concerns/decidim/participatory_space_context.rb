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
        layout :layout, **options
        before_action :authorize_participatory_space, **options
      end
    end

    included do
      include Decidim::NeedsOrganization

      helper ParticipatorySpaceHelpers, IconHelper, ContextualHelpHelper
      helper_method :current_participatory_space
      helper_method :current_participatory_space_manifest
      helper_method :current_participatory_space_context
      helper_method :help_section, :help_id
    end

    private

    def current_participatory_space_context
      :public
    end

    def current_participatory_space
      raise NotImplementedError
    end

    def current_participatory_space_manifest
      return current_participatory_space.manifest if current_participatory_space

      manifest = Decidim.find_participatory_space_manifest(
        self.class.name.demodulize.underscore.gsub("_controller", "")
      )

      raise NotImplementedError unless manifest

      manifest
    end

    def authorize_participatory_space
      enforce_permission_to :read, :participatory_space, current_participatory_space:
    end

    def layout
      current_participatory_space_manifest.context(current_participatory_space_context).layout
    end

    # Method for current user can visit the space (assembly or proces)
    def current_user_can_visit_space?
      return true unless current_participatory_space.try(:private_space?) &&
                         !current_participatory_space.try(:is_transparent?)
      return false unless current_user

      current_user.admin || current_participatory_space.users.include?(current_user)
    end

    def check_current_user_can_visit_space
      return if current_user_can_visit_space?

      flash[:alert] = I18n.t("participatory_space_private_users.not_allowed", scope: "decidim")
      redirect_to action: "index"
    end

    def help_section
      @help_section ||= Decidim::ContextualHelpSection.find_content(
        current_organization,
        help_id
      )
    end

    def help_id
      @help_id ||= current_participatory_space_manifest.name
    end
  end
end
