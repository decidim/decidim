# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters all processes of a participatory process group
    class GroupParticipatoryProcesses < Rectify::Query
      def initialize(group)
        @group = group
      end

      def query
        Decidim::ParticipatoryProcess.where(participatory_process_group: @group)
      end
    end
  end
end
