# frozen_string_literal: true

require "decidim/features/namer"

Decidim.register_feature(:proposals) do |feature|
  feature.engine = Decidim::Proposals::Engine
  feature.admin_engine = Decidim::Proposals::AdminEngine
  feature.icon = "decidim/proposals/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise "Can't destroy this feature when there are proposals" if Decidim::Proposals::Proposal.where(feature: instance).any?
  end

  feature.actions = %w(endorse vote create withdraw)

  feature.query_type = "Decidim::Proposals::ProposalsType"

  feature.settings(:global) do |settings|
    settings.attribute :vote_limit, type: :integer, default: 0
    settings.attribute :proposal_limit, type: :integer, default: 0
    settings.attribute :proposal_length, type: :integer, default: 500
    settings.attribute :proposal_edit_before_minutes, type: :integer, default: 5
    settings.attribute :maximum_votes_per_proposal, type: :integer, default: 0
    settings.attribute :can_accumulate_supports_beyond_threshold, type: :boolean, default: false
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :official_proposals_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :geocoding_enabled, type: :boolean, default: false
    settings.attribute :attachments_allowed, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :new_proposal_help_text, type: :text, translated: true, editor: true
    settings.attribute :proposal_wizard_step_1_help_text, type: :text, translated: true, editor: true
    settings.attribute :proposal_wizard_step_2_help_text, type: :text, translated: true, editor: true
    settings.attribute :proposal_wizard_step_3_help_text, type: :text, translated: true, editor: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :endorsements_enabled, type: :boolean, default: true
    settings.attribute :endorsements_blocked, type: :boolean
    settings.attribute :votes_enabled, type: :boolean
    settings.attribute :votes_blocked, type: :boolean
    settings.attribute :votes_hidden, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :creation_enabled, type: :boolean
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Proposals::Proposal"
    resource.template = "decidim/proposals/proposals/linked_proposals"
  end

  feature.register_stat :proposals_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |features, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(features, start_at, end_at).published.not_hidden.count
  end

  feature.register_stat :proposals_accepted, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |features, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(features, start_at, end_at).accepted.count
  end

  feature.register_stat :votes_count, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |features, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(features, start_at, end_at).published.not_hidden
    Decidim::Proposals::ProposalVote.where(proposal: proposals).count
  end

  feature.register_stat :endorsements_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |features, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(features, start_at, end_at).not_hidden
    Decidim::Proposals::ProposalEndorsement.where(proposal: proposals).count
  end

  feature.register_stat :comments_count, tag: :comments do |features, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(features, start_at, end_at).published.not_hidden
    Decidim::Comments::Comment.where(root_commentable: proposals).count
  end

  feature.exports :proposals do |exports|
    exports.collection do |feature_instance|
      Decidim::Proposals::Proposal
        .where(feature: feature_instance)
        .includes(:category, feature: { participatory_space: :organization })
    end

    exports.serializer Decidim::Proposals::ProposalSerializer
  end

  feature.exports :comments do |exports|
    exports.collection do |feature_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Proposals::Proposal, feature_instance
      )
    end

    exports.serializer Decidim::Comments::CommentSerializer
  end

  feature.seeds do |participatory_space|
    step_settings = if participatory_space.allows_steps?
                      { participatory_space.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true } }
                    else
                      {}
                    end

    feature = Decidim::Feature.create!(
      name: Decidim::Features::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name,
      manifest_name: :proposals,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {
        vote_limit: 0
      },
      step_settings: step_settings
    )

    if participatory_space.scope
      scopes = participatory_space.scope.descendants
      global = participatory_space.scope
    else
      scopes = participatory_space.organization.scopes
      global = nil
    end

    5.times do |n|
      author = Decidim::User.where(organization: feature.organization).all.sample
      user_group = [true, false].sample ? author.user_groups.verified.sample : nil
      state, answer = if n > 3
                        ["accepted", Decidim::Faker::Localized.sentence(10)]
                      elsif n > 2
                        ["rejected", nil]
                      elsif n > 1
                        ["evaluating", nil]
                      else
                        [nil, nil]
                      end

      proposal = Decidim::Proposals::Proposal.create!(
        feature: feature,
        category: participatory_space.categories.sample,
        scope: Faker::Boolean.boolean(0.5) ? global : scopes.sample,
        title: Faker::Lorem.sentence(2),
        body: Faker::Lorem.paragraphs(2).join("\n"),
        author: author,
        user_group: user_group,
        state: state,
        answer: answer,
        answered_at: Time.current,
        published_at: Time.current
      )

      (n % 3).times do |m|
        email = "vote-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-#{m}@example.org"
        name = "#{Faker::Name.name} #{participatory_space.id} #{n} #{m}"

        author = Decidim::User.find_or_initialize_by(email: email)
        author.update!(
          password: "password1234",
          password_confirmation: "password1234",
          name: name,
          nickname: Faker::Twitter.unique.screen_name,
          organization: feature.organization,
          tos_agreement: "1",
          confirmed_at: Time.current,
          personal_url: Faker::Internet.url,
          about: Faker::Lorem.paragraph(2)
        )

        Decidim::Proposals::ProposalVote.create!(proposal: proposal, author: author) unless proposal.answered? && proposal.rejected?
      end

      unless proposal.answered? && proposal.rejected?
        (n * 2).times do |index|
          email = "endorsement-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-endr#{index}@example.org"
          name = "#{Faker::Name.name} #{participatory_space.id} #{n} endr#{index}"

          author = Decidim::User.find_or_initialize_by(email: email)
          author.update!(
            password: "password1234",
            password_confirmation: "password1234",
            name: name,
            nickname: Faker::Twitter.unique.screen_name,
            organization: feature.organization,
            tos_agreement: "1",
            confirmed_at: Time.current
          )
          if index.even?
            group = Decidim::UserGroup.create!(
              name: Faker::Name.name,
              document_number: Faker::Code.isbn,
              phone: Faker::PhoneNumber.phone_number,
              decidim_organization_id: feature.organization.id,
              verified_at: Time.current
            )
            author.user_groups << group
            author.save!
          end
          Decidim::Proposals::ProposalEndorsement.create!(proposal: proposal, author: author, user_group: author.user_groups.first)
        end
      end

      (n % 3).times do
        author_admin = Decidim::User.where(organization: feature.organization, admin: true).all.sample

        Decidim::Proposals::ProposalNote.create!(
          proposal: proposal,
          author: author_admin,
          body: Faker::Lorem.paragraphs(2).join("\n")
        )
      end

      Decidim::Comments::Seed.comments_for(proposal)
    end
  end
end
