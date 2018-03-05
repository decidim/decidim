# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalCell < Decidim::ResultCell
      include LayoutHelper

      def show
        render
      end

      private

      def title
        model.title
      end

      def state
        model.state
      end

      def state_css
        case model.state
        when "accepted"
          "success"
        when "rejected"
          "warning"
        when "evaluating"
          "muted"
        when "withdrawn"
          "alert"
        else
          ""
        end
      end

      def body
        truncate(model.body, length: 100)
      end

      def published_at
        model.published_at.strftime('%d/%m/%Y')
      end

    end
  end
end
