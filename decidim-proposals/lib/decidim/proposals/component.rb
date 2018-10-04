# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:proposals) do |component|
  component.engine = Decidim::Proposals::Engine
  component.admin_engine = Decidim::Proposals::AdminEngine
  component.stylesheet = "decidim/proposals/proposals"
  component.icon = "decidim/proposals/icon.svg"

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are proposals" if Decidim::Proposals::Proposal.where(component: instance).any?
  end

  component.actions = %w(endorse vote create withdraw)

  component.query_type = "Decidim::Proposals::ProposalsType"

  component.permissions_class_name = "Decidim::Proposals::Permissions"

  component.settings(:global) do |settings|
    settings.attribute :vote_limit, type: :integer, default: 0
    settings.attribute :proposal_limit, type: :integer, default: 0
    settings.attribute :proposal_length, type: :integer, default: 500
    settings.attribute :proposal_edit_before_minutes, type: :integer, default: 5
    settings.attribute :threshold_per_proposal, type: :integer, default: 0
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
    settings.attribute :proposal_wizard_step_4_help_text, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :endorsements_enabled, type: :boolean, default: true
    settings.attribute :endorsements_blocked, type: :boolean
    settings.attribute :votes_enabled, type: :boolean
    settings.attribute :votes_weight_enabled, type: :boolean
    settings.attribute :votes_blocked, type: :boolean
    settings.attribute :votes_hidden, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :creation_enabled, type: :boolean
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:proposal) do |resource|
    resource.model_class_name = "Decidim::Proposals::Proposal"
    resource.template = "decidim/proposals/proposals/linked_proposals"
    resource.card = "decidim/proposals/proposal"
  end

  component.register_stat :proposals_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.except_withdrawn.not_hidden.count
  end

  component.register_stat :proposals_accepted, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).accepted.count
  end

  component.register_stat :votes_count, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.not_hidden
    Decidim::Proposals::ProposalVote.where(proposal: proposals).count
  end

  component.register_stat :endorsements_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).not_hidden
    Decidim::Proposals::ProposalEndorsement.where(proposal: proposals).count
  end

  component.register_stat :comments_count, tag: :comments do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.not_hidden
    Decidim::Comments::Comment.where(root_commentable: proposals).count
  end

  component.exports :proposals do |exports|
    exports.collection do |component_instance|
      Decidim::Proposals::Proposal
        .published
        .where(component: component_instance)
        .includes(:category, component: { participatory_space: :organization })
    end

    exports.serializer Decidim::Proposals::ProposalSerializer
  end

  component.exports :comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Proposals::Proposal, component_instance
      )
    end

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.seeds do |participatory_space|
    step_settings = if participatory_space.allows_steps?
                      { participatory_space.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true } }
                    else
                      {}
                    end

    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name,
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
      author = Decidim::User.where(organization: component.organization).all.sample
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
        component: component,
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
          organization: component.organization,
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
            organization: component.organization,
            tos_agreement: "1",
            confirmed_at: Time.current
          )
          if index.even?
            group = Decidim::UserGroup.create!(
              name: Faker::Name.name,
              document_number: Faker::Code.isbn,
              phone: Faker::PhoneNumber.phone_number,
              decidim_organization_id: component.organization.id,
              verified_at: Time.current
            )
            author.user_groups << group
            author.save!
          end
          Decidim::Proposals::ProposalEndorsement.create!(proposal: proposal, author: author, user_group: author.user_groups.first)
        end
      end

      (n % 3).times do
        author_admin = Decidim::User.where(organization: component.organization, admin: true).all.sample

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
