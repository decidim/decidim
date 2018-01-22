# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This class contains helpers needed to format ParticipatoryProcessGroups
      # in order to use them in select forms.
      #
      module ProcessUsersForSelectHelper
        # Public: A formatted collection of ParticipatoryProcessUsers to be used
        # in forms.
        #
        # Returns an Array.
        def process_users_for_select
          @process_users_for_select ||=
            Decidim::User.where(organization: current_organization).map do |user|
              [user.name, user.id]
            end
        end

        def process_users_selected
          @process_users_selected ||=
            Decidim::ParticipatoryProcessUser.where(participatory_process: current_participatory_process).map do |ppu|
              ppu.user.id
            end
        end
      end
    end
  end
end
