# frozen_string_literal: true
Decidim.register_feature(:meetings) do |feature|
  feature.engine = Decidim::Meetings::ListEngine

  feature.on(:create) do |instance|
    Decidim::Meetings::CreateMeeting.call(instance) do
      on(:error) { raise "Can't create meeting" }
    end
  end

  feature.on(:destroy) do |instance|
    Decidim::Meetings::DestroyMeeting.call(instance) do
      on(:error) { raise "Can't destroy meeting" }
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

      admin_user = process.organization.admins.first

      3.times do
        Decidim::Meetings::Meeting.create!(
          feature: feature,
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          location: Decidim::Faker::Localized.sentence,
          location_hints: Decidim::Faker::Localized.sentence,
          start_date: 3.weeks.from_now,
          end_date: 3.weeks.from_now + 4.hours,
          address: "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}",
          author: admin_user
        )
      end
    end
  end
end
