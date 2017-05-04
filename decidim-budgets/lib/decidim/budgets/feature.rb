# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:budgets) do |feature|
  feature.engine = Decidim::Budgets::ListEngine
  feature.admin_engine = Decidim::Budgets::AdminEngine
  feature.icon = "decidim/budgets/icon.svg"
  feature.stylesheet = "decidim/budgets/budgets"

  feature.actions = %(vote)

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Budgets::Project.where(feature: instance).any?
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Budgets::Project"
    resource.template = "decidim/budgets/projects/linked_projects"
  end

  feature.register_stat :projects_count, primary: true do |features, start_at, end_at|
    Decidim::Budgets::FilteredProjects.for(features, start_at, end_at).count
  end

  feature.register_stat :comments_count, tag: :comments do |features, start_at, end_at|
    projects = Decidim::Budgets::FilteredProjects.for(features, start_at, end_at)
    Decidim::Comments::Comment.where(commentable: projects).count
  end

  feature.settings(:global) do |settings|
    settings.attribute :total_budget, type: :integer, default: 100_000_000
    settings.attribute :vote_threshold_percent, type: :integer, default: 70
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :votes_enabled, type: :boolean, default: true
    settings.attribute :show_votes, type: :boolean, default: false
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :budgets).i18n_name,
        manifest_name: :budgets,
        published_at: Time.current,
        participatory_process: process
      )

      3.times do
        project = Decidim::Budgets::Project.create!(
          feature: feature,
          scope: process.organization.scopes.sample,
          category: process.categories.sample,
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          budget: Faker::Number.number(8)
        )
        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(File.dirname(__FILE__), "seeds", "city.jpeg")),
          attached_to: project
        )
        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(File.dirname(__FILE__), "seeds", "Exampledocument.pdf")),
          attached_to: project
        )
        Decidim::Comments::Seed.comments_for(project)
      end
    end
  end
end
