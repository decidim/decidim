# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query filters processes so only promoted ones are returned.
    class PromotedParticipatoryProcesses < Decidim::Query
      def query
        Decidim::ParticipatoryProcess.promoted
      end
    end
  end
end
