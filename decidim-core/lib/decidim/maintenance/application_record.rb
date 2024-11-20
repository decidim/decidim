# frozen_string_literal: true

module Decidim
  module Maintenance
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
      # rubocop:disable Style/ClassVars
      @@resource_classes = [
        "Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Conference", "Decidim::InitiativesTypeScope",
        "Decidim::ActionLog",
        "Decidim::Accountability::Result",
        "Decidim::Budgets::Budget", "Decidim::Budgets::Project",
        "Decidim::Debates::Debate",
        "Decidim::Meetings::Meeting",
        "Decidim::Proposals::CollaborativeDraft", "Decidim::Proposals::Proposal"
      ]
      @@participatory_space_classes = ["Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Conference", "Decidim::Initiative"]

      def self.with(organization)
        @@organization = organization
        self
      end

      def self.organization
        @@organization
      end

      def organization
        @@organization
      end

      def self.all_in_org
        where(decidim_organization_id: @@organization.id)
      end

      def self.participatory_space_classes
        @@participatory_space_classes.map(&:safe_constantize).compact_blank
      end

      def self.participatory_space_classes=(classes)
        @@participatory_space_classes = classes
      end

      def self.resource_classes
        @@resource_classes.map(&:safe_constantize).compact_blank
      end

      def self.resource_classes=(classes)
        @@resource_classes = classes
      end

      def self.add_resource_class(klass)
        @@resource_classes << klass
      end

      def resource_title(resource)
        if resource.respond_to?(:full_name)
          resource.full_name
        elsif resource.respond_to?(:title)
          resource.title
        elsif resource.respond_to?(:name)
          resource.name
        else
          resource.to_s
        end
      end

      def resource_name(resource)
        title = resource_title(resource)
        if title.is_a?(Hash)
          title[I18n.locale.to_s]
        else
          title
        end
      end
      # rubocop:enable Style/ClassVars
    end
  end
end
