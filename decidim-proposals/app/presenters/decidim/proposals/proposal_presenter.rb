# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < Decidim::ResourcePresenter
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

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
      def title(links: nil, extras: nil, html_escape: false, all_locales: false)
        return unless proposal

        raise "Extras has been set" unless extras.nil?
        raise "Links have been set" unless links.nil?

        super(proposal.title, nil, html_escape, all_locales)
      end

      def id_and_title(links: false, html_escape: false)
        "##{proposal.id} - #{title(links:, html_escape:)}"
      end

      def body(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless proposal

        content_handle_locale(proposal.body, all_locales, extras, links, strip_tags)
      end

      def editor_body(all_locales: false, extras: true)
        editor_locales(proposal.body, all_locales, extras:)
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
            version.changeset["decidim_proposals_proposal_state_id"] = parsed_state_change(*pending_state_change) if pending_state_change
            pending_state_change = nil
          elsif version.changeset["decidim_proposals_proposal_state_id"]
            pending_state_change = version.changeset.delete("decidim_proposals_proposal_state_id")
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

      def parsed_state_change(old_state, new_state)
        [
          translated_attribute(Decidim::Proposals::ProposalState.find_by(id: old_state)&.title),
          translated_attribute(Decidim::Proposals::ProposalState.find_by(id: new_state)&.title)
        ]
      end
    end
  end
end
