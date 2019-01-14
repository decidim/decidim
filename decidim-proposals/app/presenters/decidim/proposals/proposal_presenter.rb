# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    else
                      coauthorship = coauthorships.first
                      if coauthorship.user_group
                        Decidim::UserGroupPresenter.new(coauthorship.user_group)
                      else
                        Decidim::UserPresenter.new(coauthorship.author)
                      end
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
      def title(links: false, extras: true)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(proposal.title)
        renderer.render(links: links, extras: extras).html_safe
      end

      def body(links: false, extras: true)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(proposal.body)
        renderer.render(links: links, extras: extras).html_safe
      end
    end
  end
end
