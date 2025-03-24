# frozen_string_literal: true

module Decidim
  module Admin
    module Moderations
      # This module includes helpers to show moderation reports in admin
      module ReportsHelper
        include Decidim::Messaging::ConversationHelper
        include Decidim::ResourceHelper
        include Decidim::SanitizeHelper
        include Decidim::TranslationsHelper

        # Public: Returns the reportable's author names separated by commas.
        def reportable_author_name(reportable)
          reportable_authors = reportable.try(:authors) || [reportable.try(:author)]
          content_tag :ul, class: "reportable-authors" do
            reportable_authors.compact_blank.map do |author|
              case author
              when User
                content_tag :li do
                  link_to current_or_new_conversation_path_with(author), target: "_blank", rel: "noopener" do
                    "#{author.name} #{icon "mail-send-line"}".html_safe
                  end
                end
              when Decidim::Meetings::Meeting
                content_tag :li do
                  link_to resource_locator(author).path, target: "_blank", rel: "noopener" do
                    decidim_sanitize_translated(author.title)
                  end
                end
              when Decidim::Organization
                content_tag :li, organization_name(author)
              else
                content_tag(:li, author.name)
              end
            end.join.html_safe
          end
        end

        # Public: Renders a small preview of the content reported.
        def reported_content_for(reportable, options = {})
          cell "decidim/reported_content", reportable, options
        end

        # Public: Whether the resource has some translated attribute or not.
        def translatable_resource?(reportable)
          reportable.respond_to?(:content_original_language)
        end
      end
    end
  end
end
