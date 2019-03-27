# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterRecipients < Rectify::Query
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def query
        Rectify::Query.merge(
          OrganizationNewsletterRecipients.new(@organization),
          SelectiveNewsletterRecipientsForSpace.new(spaces)
        ).query
      end

      private

      def spaces
        @form.participatory_space_types.map do |type|
          next if type.ids.blank?
          object_class = "Decidim::#{type.manifest_name.classify}"
          object_class.constantize.where(id: type.ids.reject(&:blank?))
        end.flatten.compact
      end

    end
  end
end
