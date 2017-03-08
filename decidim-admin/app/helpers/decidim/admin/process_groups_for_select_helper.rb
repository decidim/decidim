# frozen_string_literal: true
module Decidim
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
          [[I18n.t("decidim.participatory_processes.participatory_process_groups.none"), 0]] +
          current_organization.participatory_process_groups.map do |group|
            [translated_attribute(group.name), group.id]
          end
      end
    end
  end
end
