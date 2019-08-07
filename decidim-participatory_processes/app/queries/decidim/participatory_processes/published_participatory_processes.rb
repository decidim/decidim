# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query filters published processes only.
    class PublishedParticipatoryProcesses < Rectify::Query
      def query
        Decidim::ParticipatoryProcess.published
      end
    end
  end
end
