# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Blogs
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        admin_user = Decidim::User.find_by(
          organization: participatory_space.organization,
          email: "admin@example.org"
        )

        step_settings = if participatory_space.allows_steps?
                          { participatory_space.active_step.id => { comments_enabled: true, comments_blocked: false } }
                        else
                          {}
                        end

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :blogs).i18n_name,
          manifest_name: :blogs,
          published_at: Time.current,
          participatory_space:,
          settings: {
            vote_limit: 0
          },
          step_settings:
        }

        component = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end

        number_of_records.times do |n|
          author = if n >= 3
                     Decidim::User.where(organization: component.organization).sample
                   else
                     component.organization
                   end

          params = {
            component:,
            title: Decidim::Faker::Localized.sentence(word_count: 5),
            body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 20)
            end,
            author:
          }

          post = Decidim.traceability.create!(
            Decidim::Blogs::Post,
            author,
            params,
            visibility: "all"
          )

          Decidim::Comments::Seed.comments_for(post)
        end
      end
    end
  end
end
