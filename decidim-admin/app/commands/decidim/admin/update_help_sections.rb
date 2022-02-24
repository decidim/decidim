# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a content block is updated from the admin
    # panel.
    class UpdateHelpSections < Decidim::Command
      def initialize(form, organization)
        @form = form
        @organization = organization
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        ActiveRecord::Base.transaction do
          @form.sections.each do |section|
            ContextualHelpSection.set_content(@organization, section.id, section.content)
          end
        end

        broadcast(:ok)
      end
    end
  end
end
