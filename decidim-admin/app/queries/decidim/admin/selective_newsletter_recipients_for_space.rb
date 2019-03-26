# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterRecipientsForSpace < Rectify::Query
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def query
        
        raise
        # Rectify::Query.merge(
        #   OrganizationNewsletterRecipients.new(@organization),
        #   SelectiveNewsletterRecipientsForSpace.new(@organization, @form)
        # ).query
      end
    end

    private

    def followers

    end

    def spaces
      @form.participatory_space_types.map do |type|
        next if type.ids.blank?
        object_class = "Decidim::#{type.manifest_name.classify}"
        object_class.constantize.where(id: type.ids.reject(&:blank?))
      end.flatten.compact
    end
  end
end
