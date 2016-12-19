# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:meetings) do |feature|
  feature.engine = Decidim::Meetings::ListEngine
  feature.admin_engine = Decidim::Meetings::AdminEngine
  feature.icon = "decidim/meetings/icon.svg"

  feature.on(:destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Meetings::Meeting.where(feature: instance).any?
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :meetings).i18n_name,
        manifest_name: :meetings,
        participatory_process: process
      )

      3.times do
        Decidim::Meetings::Meeting.create!(
          feature: feature,
          scope: process.organization.scopes.sample,
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          location: Decidim::Faker::Localized.sentence,
          location_hints: Decidim::Faker::Localized.sentence,
          start_time: 3.weeks.from_now,
          end_time: 3.weeks.from_now + 4.hours,
          address: "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}"
        )
      end
    end
  end
end
