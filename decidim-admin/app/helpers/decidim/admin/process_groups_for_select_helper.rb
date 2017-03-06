module Decidim
  module Admin
    module ProcessGroupsForSelectHelper

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
