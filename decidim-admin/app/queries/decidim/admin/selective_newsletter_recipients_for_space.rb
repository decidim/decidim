# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterRecipientsForSpace < Rectify::Query
      def initialize(spaces)
        @spaces = spaces
      end

      def query

        raise
        # Rectify::Query.merge(
        #   OrganizationNewsletterRecipients.new(@organization),
        #   SelectiveNewsletterRecipientsForSpace.new(@organization, @form)
        # ).query
      end
    end

    private

    def followers
      # Només s'enviarà als followes de l'espai per evitar SPAM
      Decidim::Follow.user_follower_for_participatory_spaces(spaces).uniq
    end

    def participants

    end
  end
end
