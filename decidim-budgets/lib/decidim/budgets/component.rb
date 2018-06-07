# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:budgets) do |component|
  component.engine = Decidim::Budgets::Engine
  component.admin_engine = Decidim::Budgets::AdminEngine
  component.icon = "decidim/budgets/icon.svg"
  component.stylesheet = "decidim/budgets/budgets"
  component.permissions_class_name = "Decidim::Budgets::Permissions"

  component.data_portable_entities = ["Decidim::Budgets::Order"]

  component.actions = %(vote)

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Budgets::Project.where(component: instance).any?
  end

  component.register_resource(:project) do |resource|
    resource.model_class_name = "Decidim::Budgets::Project"
    resource.template = "decidim/budgets/projects/linked_projects"
    resource.card = "decidim/budgets/project"
  end

  component.register_stat :projects_count, primary: true, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
    Decidim::Budgets::FilteredProjects.for(components, start_at, end_at).count
  end

  component.register_stat :orders_count do |components, start_at, end_at|
    orders = Decidim::Budgets::Order.where(component: components)
    orders = orders.where("created_at >= ?", start_at) if start_at.present?
    orders = orders.where("created_at <= ?", end_at) if end_at.present?
    orders.count
  end

  component.register_stat :comments_count, tag: :comments do |components, start_at, end_at|
    projects = Decidim::Budgets::FilteredProjects.for(components, start_at, end_at)
    Decidim::Comments::Comment.where(root_commentable: projects).count
  end

  component.settings(:global) do |settings|
    settings.attribute :projects_per_page, type: :integer, default: 12
    settings.attribute :total_budget, type: :integer, default: 100_000_000
    settings.attribute :vote_threshold_percent, type: :integer, default: 70
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :votes_enabled, type: :boolean, default: true
    settings.attribute :show_votes, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets).i18n_name,
      manifest_name: :budgets,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    2.times do
      project = Decidim::Budgets::Project.create!(
        component: component,
        scope: participatory_space.organization.scopes.sample,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        budget: Faker::Number.number(8)
      )

      attachment_collection = Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(5),
        collection_for: project
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "Exampledocument.pdf")),
        attachment_collection: attachment_collection,
        attached_to: project
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "city.jpeg")),
        attached_to: project
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "Exampledocument.pdf")),
        attached_to: project
      )
      Decidim::Comments::Seed.comments_for(project)
    end
  end
end
