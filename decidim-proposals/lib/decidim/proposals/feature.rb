# frozen_string_literal: true
Decidim.register_feature(:proposals) do |feature|
  feature.engine = Decidim::Proposals::Engine

  feature.on(:destroy) do |instance|
    if Decidim::Proposals::Proposal.where(feature: instance).any?
      raise "Can't destroy this feature when there are proposals"
    end
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: { "en" => "Proposals", "ca" => "Propostes" },
        manifest_name: :proposals,
        participatory_process: process
      )

      20.times do
        Decidim::Proposals::Proposal.create!(
          feature: feature,
          title: Faker::Lorem.sentence(2),
          body: Faker::Lorem.paragraphs(2).join("\n"),
          author: Decidim::User.where(organization: feature.organization).all.sample
        )
      end
    end
  end
end
