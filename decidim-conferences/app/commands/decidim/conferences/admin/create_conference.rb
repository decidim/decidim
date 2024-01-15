# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new
      # conference in the system.
      class CreateConference < Decidim::Commands::CreateResource
        fetch_form_attributes :organization, :title, :slogan, :slug, :weight, :hashtag, :description,
                              :short_description, :objectives, :location, :scopes_enabled, :scope, :start_date, :end_date,
                              :hero_image, :banner_image, :promoted, :show_statistics, :registrations_enabled, :available_slots,
                              :registration_terms

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if conference.persisted?
            add_admins_as_followers(conference)
            link_participatory_processes
            link_assemblies

            broadcast(:ok, conference)
          else
            form.errors.add(:hero_image, conference.errors[:hero_image]) if conference.errors.include? :hero_image
            form.errors.add(:banner_image, conference.errors[:banner_image]) if conference.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        def resource_class = Decidim::Conference

        def conference
          @conference ||= create_resource(soft: true)
        end

        def add_admins_as_followers(conference)
          conference.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: conference.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: conference.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end

        def participatory_processes
          @participatory_processes ||= conference.participatory_space_sibling_scope(:participatory_processes).where(id: @form.participatory_processes_ids)
        end

        def link_participatory_processes
          conference.link_participatory_space_resources(participatory_processes, "included_participatory_processes")
        end

        def assemblies
          @assemblies ||= conference.participatory_space_sibling_scope(:assemblies).where(id: @form.assemblies_ids)
        end

        def link_assemblies
          conference.link_participatory_space_resources(assemblies, "included_assemblies")
        end
      end
    end
  end
end
