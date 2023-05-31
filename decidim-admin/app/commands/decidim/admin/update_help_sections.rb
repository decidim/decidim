# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a content block is updated from the admin
    # panel.
    class UpdateHelpSections < Decidim::Command
      def initialize(form, organization, user)
        @form = form
        @organization = organization
        @user = user
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        ActiveRecord::Base.transaction do
          @form.sections.each do |section|
            next unless content_has_changed?(section)

            Decidim.traceability.perform_action!("update", ContextualHelpSection, @user, { "resource" => { "title" => section.id.humanize } }) do
              ContextualHelpSection.set_content(@organization, section.id, section.content)
              ContextualHelpSection.find_by(organization: @organization, section_id: section.id)
            end
          end
        end

        broadcast(:ok)
      end

      private

      def content_has_changed?(section)
        return if ContextualHelpSection.find_by(organization: @organization, section_id: section.id).nil? && section.content.compact_blank.blank?

        section.content != ContextualHelpSection.find_content(@organization, section.id).except("machine_translations")
      end
    end
  end
end
