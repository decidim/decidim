# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This class contains helpers needed to format ParticipatoryProcessGroups
      # in order to use them in select forms.
      #
      module ProcessGroupsForSelectHelper
        # Public: A formatted collection of ParticipatoryProcessGroups to be used
        # in forms.
        #
        # Returns an Array.
        def process_groups_for_select
          @process_groups_for_select ||=
            OrganizationParticipatoryProcessGroups.new(current_organization).map do |group|
              [translated_attribute(group.title), group.id]
            end
        end
      end
    end
  end
end
