# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:proposals) do |feature|
  feature.engine = Decidim::Proposals::Engine
  feature.admin_engine = Decidim::Proposals::AdminEngine
  feature.icon = "decidim/proposals/icon.svg"
  feature.stylesheet = "decidim/proposals/application"

  feature.on(:before_destroy) do |instance|
    if Decidim::Proposals::Proposal.where(feature: instance).any?
      raise "Can't destroy this feature when there are proposals"
    end
  end

  feature.settings(:global) do |settings|
    settings.attribute :vote_limit, type: :integer, default: 0
    settings.attribute :comments_always_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :votes_enabled, type: :boolean
    settings.attribute :votes_blocked, type: :boolean
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :creation_enabled, type: :boolean
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Proposals::Proposal"
    resource.template = "decidim/proposals/proposals/linked_proposals"
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :proposals).i18n_name,
        manifest_name: :proposals,
        participatory_process: process,
        settings: {
          vote_limit: 0
        },
        step_settings: {
          process.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true }
        }
      )

      20.times do |n|
        proposal = Decidim::Proposals::Proposal.create!(
          feature: feature,
          title: Faker::Lorem.sentence(2),
          body: Faker::Lorem.paragraphs(2).join("\n"),
          author: Decidim::User.where(organization: feature.organization).all.sample
        )

        rand(3).times do |m|
          email = "vote-author-#{process.id}-#{n}-#{m}@decidim.org"
          name = "#{Faker::Name.name} #{process.id} #{n} #{m}"

          author = Decidim::User.create!(email: email,
                                         password: "password1234",
                                         password_confirmation: "password1234",
                                         name: name,
                                         organization: feature.organization,
                                         tos_agreement: "1",
                                         confirmed_at: Time.now)

          Decidim::Proposals::ProposalVote.create!(proposal: proposal,
                                                   author: author)
        end

        Decidim::Comments::Seed.comments_for(proposal)
      end
    end
  end
end
