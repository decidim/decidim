# frozen_string_literal: true

module Decidim
  module Maintenance
    class ApplicationRecord < ::ApplicationRecord
      self.abstract_class = true

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

      def self.participatory_spaces
        [Decidim::Assembly, Decidim::ParticipatoryProcess, Decidim::Conference, Decidim::Initiative]
      end

      def resource_title(resource)
        if resource.respond_to?(:title)
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
    end
  end
end
