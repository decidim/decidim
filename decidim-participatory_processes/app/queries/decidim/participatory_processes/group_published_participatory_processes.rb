# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters published processes of a participatory process group
    class GroupPublishedParticipatoryProcesses < Rectify::Query
      def initialize(group, user = nil)
        @group = group
        @user = user
      end

      def query
        Rectify::Query.merge(
          GroupParticipatoryProcesses.new(@group),
          VisibleParticipatoryProcesses.new(@user),
          PublishedParticipatoryProcesses.new
        ).query
      end
    end
  end
end
