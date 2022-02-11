# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new
      # conference in the system.
      class CreateConference < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if conference.persisted?
            add_admins_as_followers(conference)
            link_participatory_processes
            link_assemblies
            link_consultations

            broadcast(:ok, conference)
          else
            form.errors.add(:hero_image, conference.errors[:hero_image]) if conference.errors.include? :hero_image
            form.errors.add(:banner_image, conference.errors[:banner_image]) if conference.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def conference
          @conference ||= Decidim.traceability.create(
            Conference,
            form.current_user,
            organization: form.current_organization,
            title: form.title,
            slogan: form.slogan,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            objectives: form.objectives,
            location: form.location,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            start_date: form.start_date,
            end_date: form.end_date,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            show_statistics: form.show_statistics,
            registrations_enabled: form.registrations_enabled,
            available_slots: form.available_slots || 0,
            registration_terms: form.registration_terms
          )
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

        def consultations
          @consultations ||= conference.participatory_space_sibling_scope(:consultations)
                                       .where(id: @form.consultations_ids)
        end

        def link_consultations
          conference.link_participatory_space_resources(consultations, "included_consultations")
        end
      end
    end
  end
end
