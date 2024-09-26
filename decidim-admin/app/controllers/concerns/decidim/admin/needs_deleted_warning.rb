# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    # Concern to handle warnings for deleted (trashed) resources
    module NeedsDeletedWarning
      extend ActiveSupport::Concern

      INCLUDED_RESOURCE_CLASSES = [
        Decidim::Conference,
        Decidim::ParticipatoryProcess,
        Decidim::Assembly,
        Decidim::Component,
        Decidim::Accountability::Result,
        Decidim::Blogs::Post,
        Decidim::Budgets::Budget,
        Decidim::Budgets::Project,
        Decidim::Debates::Debate,
        Decidim::Meetings::Meeting,
        Decidim::Proposals::Proposal
      ].freeze

      included do
        before_action :set_deleted_warning, if: :trashed_item?, only: [:edit, :show]
      end

      private

      def set_deleted_warning
        flash.now[:warning] = t("decidim.admin.manage_trash.deleted_items_warning")
      end

      def trashed_item?
        current_resource&.trashed?
      end

      def current_resource
        @current_resource ||= find_resource
      end

      def find_resource
        return unless current_manifest

        resource_class = current_manifest.model_class

        return unless INCLUDED_RESOURCE_CLASSES.include?(resource_class)

        find_by_slug_or_id(resource_class)
      end

      def find_by_slug_or_id(resource_class)
        if params[:slug]
          resource_class.find_by(slug: params[:slug])
        elsif params[:id]
          resource_class.find(params[:id])
        end
      end

      def current_manifest
        @current_manifest ||= [Decidim.find_resource_manifest(controller_name),
                               Decidim.find_participatory_space_manifest(controller_name),
                               Decidim.find_component_manifest(controller_name)].compact.first
      end
    end
  end
end
