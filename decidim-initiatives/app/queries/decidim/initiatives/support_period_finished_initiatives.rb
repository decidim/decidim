# frozen_string_literal: true

module Decidim
  module Initiatives
    # Class uses to retrieve initiatives that have been a long time in validating
    # state
    class SupportPeriodFinishedInitiatives < Decidim::Query
      # Retrieves the initiatives ready to be evaluated to decide if they've been
      # accepted or not.
      def query
        Decidim::Initiative
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_end_date < ?", Date.current)
      end
    end
  end
end
