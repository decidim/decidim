# frozen_string_literal: true
Decidim.register_feature(:meetings) do |feature|
  feature.component :meeting_list do |component|
    component.engine = Decidim::Meetings::ListEngine

    component.on(:create) do |instance|
      Decidim::Meetings::CreateMeeting.call(instance) do
        on(:error) { raise "Can't create meeting" }
      end
    end

    component.on(:destroy) do |instance|
      Decidim::Meetings::DestroyMeeting.call(instance) do
        on(:error) { raise "Can't destroy meeting" }
      end
    end
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Faker::Localized.sentence(2),
        manifest_name: :meetings,
        participatory_process: process
      )

      meeting_component = Decidim::Component.create!(
        name: Decidim::Faker::Localized.sentence(2),
        manifest_name: :meeting_list,
        feature: feature,
        step: process.steps.sample
      )

      Decidim::Meetings::Meeting.create!(
        component: meeting_component,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        location_hints: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        start_date: 3.weeks.from_now,
        end_date: 3.weeks.from_now + 4.hours,
        address: Faker::Lorem.paragraph(3)
      )
    end
  end
end
