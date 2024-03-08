# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process group in the system.
      class CreateParticipatoryProcessGroup < Decidim::Commands::CreateResource
        fetch_form_attributes :organization, :title, :description, :hashtag, :group_url, :hero_image,
                              :developer_group, :local_area, :meta_scope, :participatory_scope, :participatory_structure,
                              :target, :promoted

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if group.persisted?
            Decidim::ContentBlocksCreator.new(group).create_default!

            broadcast(:ok, group)
          else
            form.errors.add(:hero_image, group.errors[:hero_image]) if group.errors.include? :hero_image
            form.errors.add(:banner_image, group.errors[:banner_image]) if group.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        protected

        def group
          @group ||= create_resource(soft: true)
        end

        def resource_class = Decidim::ParticipatoryProcessGroup

        def attributes
          super.merge({ participatory_processes: })
        end

        def participatory_processes
          Decidim::ParticipatoryProcess.where(id: form.participatory_process_ids)
        end
      end
    end
  end
end
