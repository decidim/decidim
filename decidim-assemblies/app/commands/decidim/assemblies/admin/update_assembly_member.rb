# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating an assembly
      # member in the system.
      class UpdateAssemblyMember < Decidim::Commands::UpdateResource
        fetch_file_attributes :non_user_avatar

        fetch_form_attributes :full_name, :gender, :birthday, :birthplace, :ceased_date, :designation_date,
                              :position, :position_other, :weight, :user

        private

        def extra_params
          {
            resource: {
              title: resource.full_name
            },
            participatory_space: {
              title: resource.assembly.title
            }
          }
        end
      end
    end
  end
end
