# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # assembly in the system.
      class CreateAssembly < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :subtitle, :weight, :slug, :hashtag, :description, :short_description,
                              :hero_image, :banner_image, :promoted, :scopes_enabled, :scope, :area, :parent,
                              :private_space, :developer_group, :local_area, :target, :participatory_scope,
                              :participatory_structure, :meta_scope, :show_statistics, :purpose_of_action,
                              :composition, :assembly_type, :creation_date, :created_by, :created_by_other,
                              :duration, :included_at, :closing_date, :closing_date_reason, :internal_organisation,
                              :is_transparent, :special_features, :twitter_handler, :facebook_handler,
                              :instagram_handler, :youtube_handler, :github_handler, :announcement, :organization

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if assembly.persisted?
            add_admins_as_followers(assembly)
            link_participatory_processes(assembly)
            Decidim::ContentBlocksCreator.new(assembly).create_default!

            broadcast(:ok, assembly)
          else
            form.errors.add(:hero_image, assembly.errors[:hero_image]) if assembly.errors.include? :hero_image
            form.errors.add(:banner_image, assembly.errors[:banner_image]) if assembly.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        def resource_class = Decidim::Assembly

        def assembly
          @assembly ||= create_resource(soft: true)
        end

        def add_admins_as_followers(assembly)
          assembly.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: assembly.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: assembly.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end

        def participatory_processes(assembly)
          @participatory_processes ||= assembly.participatory_space_sibling_scope(:participatory_processes).where(id: @form.participatory_processes_ids)
        end

        def link_participatory_processes(assembly)
          assembly.link_participatory_space_resources(participatory_processes(assembly), "included_participatory_processes")
        end
      end
    end
  end
end
