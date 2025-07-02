# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    #
    # Decorator for collaborative texts suggestions.
    #
    class SuggestionPresenter < Decidim::ResourcePresenter
      include Decidim::ApplicationHelper

      delegate :changeset, :status, :created_at, :author, to: :suggestion
      # A summary to print in the UI
      def summary
        txt = type == :remove ? original : text
        @summary ||= I18n.t("decidim.collaborative_texts.suggestion.#{type}_html", text: txt.truncate(150))
      end

      # A text representation of the changeset. Without HTML.
      def text
        @text ||= ActionView::Base.full_sanitizer.sanitize(changeset["replace"]&.join(" ")&.strip).to_s
      end

      def original
        @original ||= ActionView::Base.full_sanitizer.sanitize(changeset["original"]&.join(" ")&.strip).to_s
      end

      def suggestion
        __getobj__
      end

      # Render the suggestion title
      #
      # Returns a String.
      def title(links: nil, extras: nil, html_escape: false, all_locales: false)
        raise "Links have been set" unless links.nil?
        raise "Extras have been set" unless extras.nil?

        super(suggestion.document.title, html_escape, all_locales)
      end

      def type
        return :remove if text.blank?
        return :add if text.include?(original.to_s)

        :replace
      end

      def safe_json
        {
          id:,
          changeset:,
          summary:,
          status:,
          type:,
          createdAt: created_at
        }
      end
    end
  end
end
