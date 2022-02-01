# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters all processes of a participatory process group
    class GroupParticipatoryProcesses < Decidim::Query
      def initialize(group)
        @group = group
      end

      def query
        Decidim::ParticipatoryProcess.where(participatory_process_group: @group).order(weight: :asc)
      end
    end
  end
end
