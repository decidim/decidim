# frozen_string_literal: true

module Decidim
  module Proposals
    # This cells renders a small preview of the `Proposal` that is
    # used in the moderations panel.
    class ReportedContentCell < Decidim::ReportedContentCell
      def show
        render :show
      end
    end
  end
end
