# frozen_string_literal: true

require "decidim/features/namer"

Decidim.register_feature(:meetings) do |feature|
  feature.engine = Decidim::Meetings::Engine
  feature.admin_engine = Decidim::Meetings::AdminEngine
  feature.icon = "decidim/meetings/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Meetings::Meeting.where(feature: instance).any?
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Meetings::Meeting"
    resource.template = "decidim/meetings/meetings/linked_meetings"
  end

  feature.register_stat :meetings_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |features, start_at, end_at|
    meetings = Decidim::Meetings::Meeting.where(feature: features)
    meetings = meetings.where("created_at >= ?", start_at) if start_at.present?
    meetings = meetings.where("created_at <= ?", end_at) if end_at.present?
    meetings.count
  end

  feature.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.seeds do |process|
    feature = Decidim::Feature.create!(
      name: Decidim::Features::Namer.new(process.organization.available_locales, :meetings).i18n_name,
      published_at: Time.current,
      manifest_name: :meetings,
      participatory_process: process
    )

    if process.scope
      scopes = process.scope.descendants
      global = process.scope
    else
      scopes = process.organization.scopes
      global = nil
    end

    3.times do
      meeting = Decidim::Meetings::Meeting.create!(
        feature: feature,
        scope: Faker::Boolean.boolean(0.5) ? global : scopes.sample,
        category: process.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        location: Decidim::Faker::Localized.sentence,
        location_hints: Decidim::Faker::Localized.sentence,
        start_time: 3.weeks.from_now,
        end_time: 3.weeks.from_now + 4.hours,
        address: "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}",
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "city.jpeg")),
        attached_to: meeting
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "Exampledocument.pdf")),
        attached_to: meeting
      )
    end
  end
end
