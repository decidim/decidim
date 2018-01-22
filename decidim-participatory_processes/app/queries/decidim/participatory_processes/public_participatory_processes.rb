# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query filters published processes only.
    class PublicParticipatoryProcesses < Rectify::Query
      def query
        Decidim::ParticipatoryProcess.public_process
      end
    end
  end
end
