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

      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    else
                      coauthorship = coauthorships.first
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
      def title(links: false, extras: true, html_escape: false)
        text = proposal.title
        text = decidim_html_escape(text) if html_escape

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
        renderer.render(links: links, extras: extras).html_safe
      end

      def body(links: false, extras: true, strip_tags: false)
        text = proposal.body
        text = strip_tags(text) if strip_tags

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
        text = renderer.render(links: links, extras: extras).html_safe

        text = Decidim::ContentRenderers::LinkRenderer.new(text).render if links
        text
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
    end
  end
end
