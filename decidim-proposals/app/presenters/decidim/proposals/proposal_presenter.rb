# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    else
                      coauthorship = coauthorships.includes(:author, :user_group).first
                      coauthorship.user_group&.presenter || coauthorship.author.presenter
                    end
      end

      def proposal
        __getobj__
      end

      def proposal_path
        Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      def display_mention
        link_to title, proposal_path
      end

      # Render the proposal title
      #
      # links - should render hashtags as links?
      # extras - should include extra hashtags?
      #
      # Returns a String.
      def title(links: false, extras: true, html_escape: false, all_locales: false)
        return unless proposal

        handle_locales(proposal.title, all_locales) do |content|
          content = decidim_html_escape(content) if html_escape

          renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
          renderer.render(links: links, extras: extras).html_safe
        end
      end

      def id_and_title(links: false, extras: true, html_escape: false)
        "##{proposal.id} - #{title(links: links, extras: extras, html_escape: html_escape)}"
      end

      def body(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless proposal

        handle_locales(proposal.body, all_locales) do |content|
          content = strip_tags(sanitize_text(content)) if strip_tags

          renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
          content = renderer.render(links: links, extras: extras).html_safe

          content = Decidim::ContentRenderers::LinkRenderer.new(content).render if links
          content
        end
      end

      # Returns the proposal versions, hiding not published answers
      #
      # Returns an Array.
      def versions
        version_state_published = false
        pending_state_change = nil

        proposal.versions.map do |version|
          state_published_change = version.changeset["state_published_at"]
          version_state_published = state_published_change.last.present? if state_published_change

          if version_state_published
            version.changeset["state"] = pending_state_change if pending_state_change
            pending_state_change = nil
          elsif version.changeset["state"]
            pending_state_change = version.changeset.delete("state")
          end

          next if version.event == "update" && Decidim::Proposals::DiffRenderer.new(version).diff.empty?

          version
        end.compact
      end

      delegate :count, to: :versions, prefix: true

      def resource_manifest
        proposal.class.resource_manifest
      end

      private

      def sanitize_unordered_lists(text)
        text.gsub(%r{(?=.*</ul>)(?!.*?<li>.*?</ol>.*?</ul>)<li>}) { |li| "#{li}• " }
      end

      def sanitize_ordered_lists(text)
        i = 0

        text.gsub(%r{(?=.*</ol>)(?!.*?<li>.*?</ul>.*?</ol>)<li>}) do |li|
          i += 1

          li + "#{i}. "
        end
      end

      def add_line_feeds_to_paragraphs(text)
        text.gsub("</p>") { |p| "#{p}\n\n" }
      end

      def add_line_feeds_to_list_items(text)
        text.gsub("</li>") { |li| "#{li}\n" }
      end

      # Adds line feeds after the paragraph and list item closing tags.
      #
      # Returns a String.
      def add_line_feeds(text)
        add_line_feeds_to_paragraphs(add_line_feeds_to_list_items(text))
      end

      # Maintains the paragraphs and lists separations with their bullet points and
      # list numberings where appropriate.
      #
      # Returns a String.
      def sanitize_text(text)
        add_line_feeds(sanitize_ordered_lists(sanitize_unordered_lists(text)))
      end

      def handle_locales(content, all_locales, &block)
        if all_locales
          content.each_with_object({}) do |(key, value), parsed_content|
            parsed_content[key] = if key == "machine_translations"
                                    handle_locales(value, all_locales, &block)
                                  else
                                    block.call(value)
                                  end
          end
        else
          yield(translated_attribute(content))
        end
      end
    end
  end
end
