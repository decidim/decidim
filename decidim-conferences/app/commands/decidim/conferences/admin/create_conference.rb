# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new
      # conference in the system.
      class CreateConference < Decidim::Commands::CreateResource
        fetch_file_attributes :hero_image, :banner_image

        fetch_form_attributes :organization, :title, :slogan, :slug, :weight, :description,
                              :short_description, :objectives, :location, :taxonomizations, :start_date, :end_date,
                              :promoted, :show_statistics, :registrations_enabled, :available_slots, :registration_terms

        private

        def run_after_hooks
          add_admins_as_followers
          link_participatory_processes
          link_assemblies
        end

        def resource_class = Decidim::Conference

        def add_admins_as_followers
          resource.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: resource.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: resource.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form).call
          end
        end

        def participatory_processes
          @participatory_processes ||= resource.participatory_space_sibling_scope(:participatory_processes).where(id: form.participatory_processes_ids)
        end

        def link_participatory_processes
          resource.link_participatory_space_resources(participatory_processes, "included_participatory_processes")
        end

        def assemblies
          @assemblies ||= resource.participatory_space_sibling_scope(:assemblies).where(id: form.assemblies_ids)
        end

        def link_assemblies
          resource.link_participatory_space_resources(assemblies, "included_assemblies")
        end
      end
    end
  end
end
