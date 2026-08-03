# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < Decidim::ResourcePresenter
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    else
                      coauthorships.includes(:author).first.author.presenter
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
      # Returns a String.
      def title(html_escape: false, all_locales: false)
        return unless proposal

        super(proposal.title, html_escape, all_locales)
      end

      def id_and_title(html_escape: false)
        "##{proposal.id} - #{title(html_escape:)}"
      end

      def body(links: false, strip_tags: false, all_locales: false)
        return unless proposal

        content_handle_locale(proposal.body, all_locales, links, strip_tags)
      end

      def editor_body(all_locales: false)
        editor_locales(proposal.body, all_locales)
      end

      # Returns the proposal versions, hiding not published answers
      #
      # Returns an Array.
      def versions
        version_status_published = false
        pending_status_change = nil

        proposal.versions.map do |version|
          status_published_change = version.changeset["status_published_at"]
          version_status_published = status_published_change.last.present? if status_published_change

          if version_status_published
            version.changeset["decidim_proposals_proposal_status_id"] = parsed_status_change(*pending_status_change) if pending_status_change
            pending_status_change = nil
          elsif version.changeset["decidim_proposals_proposal_status_id"]
            pending_status_change = version.changeset.delete("decidim_proposals_proposal_status_id")
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

      def parsed_status_change(old_status, new_status)
        [
          translated_attribute(Decidim::Proposals::ProposalStatus.find_by(id: old_status)&.title),
          translated_attribute(Decidim::Proposals::ProposalStatus.find_by(id: new_status)&.title)
        ]
      end
    end
  end
end
