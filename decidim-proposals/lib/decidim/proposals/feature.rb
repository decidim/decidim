# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:proposals) do |feature|
  feature.engine = Decidim::Proposals::Engine
  feature.admin_engine = Decidim::Proposals::AdminEngine
  feature.icon = "decidim/proposals/icon.svg"

  feature.on(:before_destroy) do |instance|
    if Decidim::Proposals::Proposal.where(feature: instance).any?
      raise "Can't destroy this feature when there are proposals"
    end
  end

  feature.settings(:step) do |settings|
    settings.attribute :votes_enabled, type: :boolean
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :proposals).i18n_name,
        manifest_name: :proposals,
        participatory_process: process
      )

      20.times do
        proposal = Decidim::Proposals::Proposal.create!(
          feature: feature,
          title: Faker::Lorem.sentence(2),
          body: Faker::Lorem.paragraphs(2).join("\n"),
          author: Decidim::User.where(organization: feature.organization).all.sample
        )

        Decidim::Comments::Seed.comments_for(proposal)
      end
    end
  end
end
