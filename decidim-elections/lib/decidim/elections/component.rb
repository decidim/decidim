# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:elections) do |component|
  component.engine = Decidim::Elections::Engine
  component.admin_engine = Decidim::Elections::AdminEngine
  component.icon = "decidim/elections/icon.svg"
  component.stylesheet = "decidim/elections/elections"
  component.permissions_class_name = "Decidim::Elections::Permissions"
  component.query_type = "Decidim::Elections::ElectionsType"
  # component.on(:before_destroy) do |instance|
  #   # Code executed before removing the component
  # end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(vote)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :elections_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    Decidim::Elections::Election.where(component: components).count
  end

  component.register_resource(:election) do |resource|
    resource.model_class_name = "Decidim::Elections::Election"
    resource.actions = %w(vote)
    resource.card = "decidim/elections/election"
  end

  component.register_resource(:question) do |resource|
    resource.model_class_name = "Decidim::Elections::Question"
  end

  component.register_resource(:answer) do |resource|
    resource.model_class_name = "Decidim::Elections::Answer"
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :elections).i18n_name,
      manifest_name: :elections,
      published_at: Time.current,
      participatory_space: participatory_space
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    3.times do
      election = Decidim.traceability.create!(
        Decidim::Elections::Election,
        admin_user,
        {
          component: component,
          title: Decidim::Faker::Localized.sentence(2),
          subtitle: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          start_time: 3.weeks.from_now,
          end_time: 3.weeks.from_now + 4.hours,
          published_at: Faker::Boolean.boolean(0.5) ? 1.week.ago : nil
        },
        visibility: "all"
      )

      2.times do
        question = Decidim.traceability.create!(
          Decidim::Elections::Question,
          admin_user,
          {
            election: election,
            title: Decidim::Faker::Localized.sentence(2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(3)
            end,
            max_selections: Faker::Number.between(0, 5),
            weight: Faker::Number.number(1),
            random_answers_order: Faker::Boolean.boolean(0.5)
          },
          visibility: "all"
        )

        Faker::Number.between(2, 5).times do
          answer = Decidim.traceability.create!(
            Decidim::Elections::Answer,
            admin_user,
            {
              question: question,
              title: Decidim::Faker::Localized.sentence(2),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(3)
              end,
              weight: Faker::Number.number(1)
            },
            visibility: "all"
          )

          Decidim::Attachment.create!(
            title: Decidim::Faker::Localized.sentence(2),
            description: Decidim::Faker::Localized.sentence(5),
            file: File.new(File.join(__dir__, "seeds", "city.jpeg")),
            attached_to: answer
          )
        end
      end
    end
  end
end
