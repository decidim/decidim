# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query filters published processes only.
    class PublishedParticipatoryProcesses < Decidim::Query
      def query
        Decidim::ParticipatoryProcess.published.not_deleted
      end
    end
  end
end
