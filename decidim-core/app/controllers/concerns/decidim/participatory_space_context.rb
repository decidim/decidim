# frozen_string_literal: true

module Decidim
  # This module contains all the logic needed for a controller to render a participatory space
  # public layout.
  #
  module ParticipatorySpaceContext
    extend ActiveSupport::Concern

    included do
      include Decidim::NeedsOrganization
      include Decidim::UserRoleChecker

      helper ParticipatorySpaceHelpers, IconHelper, ContextualHelpHelper
      helper_method :current_participatory_space
      helper_method :context_breadcrumb_items
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

    # Overwrite this method in your component controller to define
    # the breadcrumb element to be shown. The item may contain the following
    # keys with their respective values:
    # * label - The text to use in the breadcrumb element. For example, the
    #           title of the space (mandatory).
    # * url - The url of the resource (optional).
    # * active - Whether the item is active (optional).
    # * dropdown_cell - When this value is present is used to generate a dropdown
    #                   associated to the item (optional).
    # * resource - The resource of the item. This value is passed to the
    #              dropdown cell, so it is mandatory if the dropdown cell is
    #              present.
    def current_participatory_space_breadcrumb_item
      return {} if current_participatory_space.blank?

      {
        label: current_participatory_space.title,
        url: Decidim::ResourceLocatorPresenter.new(current_participatory_space).path,
        active: true,
        dropdown_cell: current_participatory_space_manifest.breadcrumb_cell,
        resource: current_participatory_space
      }
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

    def context_breadcrumb_items
      @context_breadcrumb_items ||= [current_participatory_space_breadcrumb_item].flatten.compact_blank
    end

    def layout
      current_participatory_space_manifest.context(current_participatory_space_context).layout
    end

    # Method for current user can visit the space (assembly or process)
    def current_user_can_visit_space?
      return true unless current_participatory_space.try(:private_space?) &&
                         !current_participatory_space.try(:is_transparent?)
      return false unless current_user
      return true if current_user.admin?
      return true if user_has_any_role?(current_user, current_participatory_space, broad_check: true)

      current_participatory_space.users.include?(current_user)
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
