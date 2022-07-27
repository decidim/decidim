# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:debates) do |component|
  component.engine = Decidim::Debates::Engine
  component.admin_engine = Decidim::Debates::AdminEngine
  component.icon = "media/images/decidim_debates.svg"
  component.permissions_class_name = "Decidim::Debates::Permissions"

  component.query_type = "Decidim::Debates::DebatesType"
  component.data_portable_entities = ["Decidim::Debates::Debate"]

  component.newsletter_participant_entities = ["Decidim::Debates::Debate"]

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Debates::Debate.where(component: instance).any?
  end

  component.settings(:global) do |settings|
    settings.attribute :scopes_enabled, type: :boolean, default: false
    settings.attribute :scope_id, type: :scope
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :endorsements_enabled, type: :boolean, default: true
    settings.attribute :endorsements_blocked, type: :boolean
    settings.attribute :creation_enabled, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :debates_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    Decidim::Debates::Debate.where(component: components).not_hidden.count
  end

  component.register_stat :followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, _start_at, _end_at|
    debates_ids = Decidim::Debates::Debate.where(component: components).not_hidden.pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Debates::Debate", decidim_followable_id: debates_ids).count
  end

  component.register_stat :endorsements_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    debates_ids = Decidim::Debates::Debate.where(component: components).not_hidden.pluck(:id)
    Decidim::Endorsement.where(resource_id: debates_ids, resource_type: Decidim::Debates::Debate.name).count
  end

  component.register_resource(:debate) do |resource|
    resource.model_class_name = "Decidim::Debates::Debate"
    resource.card = "decidim/debates/debate"
    resource.reported_content_cell = "decidim/debates/reported_content"
    resource.searchable = true
    resource.actions = %w(create endorse comment)
  end

  component.actions = %w(create endorse comment)

  component.exports :comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Debates::Debate, component_instance
      )
    end

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "user@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :debates).i18n_name,
      manifest_name: :debates,
      published_at: Time.current,
      participatory_space:
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    5.times do |x|
      finite = x != 2
      if finite
        start_time = [rand(1..20).weeks.from_now, rand(1..20).weeks.ago].sample
        end_time = start_time + [rand(1..4).hours, rand(1..20).days].sample
      else
        start_time = nil
        end_time = nil
      end
      params = {
        component:,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        start_time:,
        end_time:,
        author: component.organization
      }

      debate = Decidim.traceability.create!(
        Decidim::Debates::Debate,
        admin_user,
        params,
        visibility: "all"
      )

      Decidim::Comments::Seed.comments_for(debate)
    end

    closed_debate = Decidim::Debates::Debate.last
    closed_debate.conclusions = Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      Decidim::Faker::Localized.paragraph(sentence_count: 3)
    end
    closed_debate.closed_at = Time.current
    closed_debate.save!

    params = {
      component:,
      category: participatory_space.categories.sample,
      title: Decidim::Faker::Localized.sentence(word_count: 2),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      author: user
    }

    Decidim.traceability.create!(
      Decidim::Debates::Debate,
      user,
      params,
      visibility: "all"
    )
  end
end
