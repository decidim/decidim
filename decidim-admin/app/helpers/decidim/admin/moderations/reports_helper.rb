# frozen_string_literal: true

module Decidim
  module Admin
    module Moderations
      # This module includes helpers to show moderation reports in admin
      module ReportsHelper
        include Decidim::Messaging::ConversationHelper

        # Public: Returns the reportable's author names separated by commas.
        def reportable_author_name(reportable)
          reportable_authors = reportable.try(:authors) || [reportable.try(:normalized_author)]
          content_tag :ul, class: "reportable-authors" do
            reportable_authors.select(&:present?).map do |author|
              if author.is_a? User
                content_tag :li do
                  link_to current_or_new_conversation_path_with(author), target: "_blank" do
                    "#{author.name} #{icon "envelope-closed"}".html_safe
                  end
                end
              else
                content_tag(:li, author.name)
              end
            end.join("").html_safe
          end
        end

        # Public: Renders a small preview of the content reported.
        def reported_content_for(reportable, options = {})
          cell "decidim/reported_content", reportable, options
        end

        # Public: Renders an extract of the content reported in a text format.
        def reported_content_excerpt_for(reportable, options = {})
          I18n.with_locale(options.fetch(:locale, I18n.locale)) do
            reportable_content = reportable.reported_attributes.map do |attribute_name|
              attribute_value = reportable.attributes.with_indifferent_access[attribute_name]
              next translated_attribute(attribute_value) if attribute_value.is_a? Hash

              attribute_value
            end
            reportable_content.filter(&:present?).join(". ").truncate(options.fetch(:limit, 100))
          end
        end

        # Public: Whether the resource has some translated attribute or not.
        def translatable_resource?(reportable)
          reportable.respond_to?(:content_original_language)
        end
      end
    end
  end
end
