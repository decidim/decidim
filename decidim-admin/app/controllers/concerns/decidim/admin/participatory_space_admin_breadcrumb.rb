# frozen_string_literal: true

module Decidim
  module Admin
    # This module contains all the logic needed to render breadcrumb items in
    # the context of participatory spaces
    module ParticipatorySpaceAdminBreadcrumb
      extend ActiveSupport::Concern

      included do
        include Decidim::TranslatableAttributes

        helper_method :context_breadcrumb_items
      end

      private

      def context_breadcrumb_items
        @context_breadcrumb_items ||= [current_participatory_space_breadcrumb_item].flatten.compact_blank
      end

      def current_participatory_space_path
        Decidim::ResourceLocatorPresenter.new(current_participatory_space).edit
      end

      def current_participatory_space_breadcrumb_item
        return {} if current_participatory_space.blank?

        {
          label: translated_attribute(current_participatory_space.title),
          url: current_participatory_space_path,
          active: true,
          resource: current_participatory_space
        }
      end
    end
  end
end
