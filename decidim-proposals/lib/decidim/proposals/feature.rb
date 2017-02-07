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

  feature.settings(:global) do |settings|
    settings.attribute :vote_limit, type: :integer, default: 0
    settings.attribute :comments_always_enabled, type: :boolean, default: true
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :official_proposals_enabled, type: :boolean, default: true
    settings.attribute :scoped_proposals_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :votes_enabled, type: :boolean
    settings.attribute :votes_blocked, type: :boolean
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :creation_enabled, type: :boolean
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
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
        published_at: Time.current,
        participatory_process: process,
        settings: {
          vote_limit: 0
        },
        step_settings: {
          process.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true }
        }
      )
      categories = feature.participatory_process.categories
      scopes = feature.organization.scopes

      20.times do |n|
        proposal = Decidim::Proposals::Proposal.create!(
          feature: feature,
          category: categories.sample,
          scope: scopes.sample,
          title: Faker::Lorem.sentence(2),
          body: Faker::Lorem.paragraphs(2).join("\n"),
          author: Decidim::User.where(organization: feature.organization).all.sample
        )

        if n > 15
          proposal.state = "accepted"
          proposal.answered_at = Time.current
          proposal.save!
        elsif n > 9
          proposal.state = "rejected"
          proposal.answered_at = Time.current
          proposal.answer = Decidim::Faker::Localized.sentence(10)
          proposal.save!
        end

        rand(3).times do |m|
          email = "vote-author-#{process.id}-#{n}-#{m}@decidim.org"
          name = "#{Faker::Name.name} #{process.id} #{n} #{m}"

          author = Decidim::User.create!(email: email,
                                         password: "password1234",
                                         password_confirmation: "password1234",
                                         name: name,
                                         organization: feature.organization,
                                         tos_agreement: "1",
                                         confirmed_at: Time.current,
                                         comments_notifications: true,
                                         replies_notifications: true)

          Decidim::Proposals::ProposalVote.create!(proposal: proposal,
                                                   author: author)
        end

        Decidim::Comments::Seed.comments_for(proposal)
      end
    end
  end
end
