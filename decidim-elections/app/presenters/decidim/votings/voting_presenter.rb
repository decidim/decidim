# frozen_string_literal: true

module Decidim
  module Votings
    #
    # Decorator for voting
    #
    class VotingPresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def voting
        __getobj__
      end

      def title
        content = translated_attribute(voting.title)
        decidim_html_escape(content)
      end
    end
  end
end
