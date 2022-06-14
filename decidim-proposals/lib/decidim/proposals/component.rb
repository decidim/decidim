# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/meetings"

Decidim.register_component(:proposals) do |component|
  component.engine = Decidim::Proposals::Engine
  component.admin_engine = Decidim::Proposals::AdminEngine
  component.stylesheet = "decidim/proposals/proposals"
  component.icon = "media/images/decidim_proposals.svg"

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are proposals" if Decidim::Proposals::Proposal.where(component: instance).any?
  end

  component.data_portable_entities = ["Decidim::Proposals::Proposal"]

  component.newsletter_participant_entities = ["Decidim::Proposals::Proposal"]

  component.actions = %w(endorse vote create withdraw amend comment vote_comment)

  component.query_type = "Decidim::Proposals::ProposalsType"

  component.permissions_class_name = "Decidim::Proposals::Permissions"

  POSSIBLE_SORT_ORDERS = %w(default random recent most_endorsed most_voted most_commented most_followed with_more_authors).freeze

  component.settings(:global) do |settings|
    settings.attribute :scopes_enabled, type: :boolean, default: false
    settings.attribute :scope_id, type: :scope
    settings.attribute :vote_limit, type: :integer, default: 0
    settings.attribute :minimum_votes_per_user, type: :integer, default: 0
    settings.attribute :proposal_limit, type: :integer, default: 0
    settings.attribute :proposal_length, type: :integer, default: 500
    settings.attribute :proposal_edit_time, type: :enum, default: "limited", choices: -> { %w(limited infinite) }
    settings.attribute :proposal_edit_before_minutes, type: :integer, default: 5
    settings.attribute :threshold_per_proposal, type: :integer, default: 0
    settings.attribute :can_accumulate_supports_beyond_threshold, type: :boolean, default: false
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :default_sort_order, type: :select, default: "default", choices: -> { POSSIBLE_SORT_ORDERS }
    settings.attribute :official_proposals_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: false
    settings.attribute :geocoding_enabled, type: :boolean, default: false
    settings.attribute :attachments_allowed, type: :boolean, default: false
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :collaborative_drafts_enabled, type: :boolean, default: false
    settings.attribute :participatory_texts_enabled,
                       type: :boolean, default: false,
                       readonly: ->(context) { Decidim::Proposals::Proposal.where(component: context[:component]).any? }
    settings.attribute :amendments_enabled, type: :boolean, default: false
    settings.attribute :amendments_wizard_help_text, type: :text, translated: true, editor: true, required: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :new_proposal_body_template, type: :text, translated: true, editor: true, required: false
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
    settings.attribute :votes_blocked, type: :boolean
    settings.attribute :votes_hidden, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :creation_enabled, type: :boolean, readonly: ->(context) { context[:component].settings[:participatory_texts_enabled] }
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :publish_answers_immediately, type: :boolean, default: true
    settings.attribute :answers_with_costs, type: :boolean, default: false
    settings.attribute :default_sort_order, type: :select, include_blank: true, choices: -> { POSSIBLE_SORT_ORDERS }
    settings.attribute :amendment_creation_enabled, type: :boolean, default: true
    settings.attribute :amendment_reaction_enabled, type: :boolean, default: true
    settings.attribute :amendment_promotion_enabled, type: :boolean, default: true
    settings.attribute :amendments_visibility,
                       type: :enum, default: "all",
                       choices: -> { Decidim.config.amendments_visibility_options }
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :automatic_hashtags, type: :text, editor: false, required: false
    settings.attribute :suggested_hashtags, type: :text, editor: false, required: false
  end

  component.register_resource(:proposal) do |resource|
    resource.model_class_name = "Decidim::Proposals::Proposal"
    resource.template = "decidim/proposals/proposals/linked_proposals"
    resource.card = "decidim/proposals/proposal"
    resource.reported_content_cell = "decidim/proposals/reported_content"
    resource.actions = %w(endorse vote amend comment vote_comment)
    resource.searchable = true
  end

  component.register_resource(:collaborative_draft) do |resource|
    resource.model_class_name = "Decidim::Proposals::CollaborativeDraft"
    resource.card = "decidim/proposals/collaborative_draft"
    resource.reported_content_cell = "decidim/proposals/collaborative_drafts/reported_content"
  end

  component.register_stat :proposals_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.except_withdrawn.not_hidden.count
  end

  component.register_stat :proposals_accepted, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).accepted.not_hidden.count
  end

  component.register_stat :supports_count, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.not_hidden
    Decidim::Proposals::ProposalVote.where(proposal: proposals).count
  end

  component.register_stat :endorsements_count, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).not_hidden
    proposals.sum(:endorsements_count)
  end

  component.register_stat :comments_count, tag: :comments do |components, start_at, end_at|
    proposals = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.not_hidden
    proposals.sum(:comments_count)
  end

  component.register_stat :followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
    proposals_ids = Decidim::Proposals::FilteredProposals.for(components, start_at, end_at).published.not_hidden.pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Proposals::Proposal", decidim_followable_id: proposals_ids).count
  end

  component.exports :proposals do |exports|
    exports.collection do |component_instance, user|
      space = component_instance.participatory_space

      collection = Decidim::Proposals::Proposal
                   .published
                   .where(component: component_instance)
                   .includes(:scope, :category, :component)

      if space.user_roles(:valuator).where(user: user).any?
        collection.with_valuation_assigned_to(user, space)
      else
        collection
      end
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Proposals::ProposalSerializer
  end

  component.exports :proposal_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Proposals::Proposal, component_instance
      ).includes(:author, :user_group, root_commentable: { component: { participatory_space: :organization } })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.imports :proposals do |imports|
    imports.form_view = "decidim/proposals/admin/imports/proposals_fields"
    imports.form_class_name = "Decidim::Proposals::Admin::ProposalsFileImportForm"

    imports.messages do |msg|
      msg.set(:resource_name) { |count: 1| I18n.t("decidim.proposals.admin.imports.resources.proposals", count: count) }
      msg.set(:title) { I18n.t("decidim.proposals.admin.imports.title.proposals") }
      msg.set(:label) { I18n.t("decidim.proposals.admin.imports.label.proposals") }
      msg.set(:help) { I18n.t("decidim.proposals.admin.imports.help.proposals") }
    end

    imports.creator Decidim::Proposals::Import::ProposalCreator
  end

  component.imports :answers do |imports|
    imports.messages do |msg|
      msg.set(:resource_name) { |count: 1| I18n.t("decidim.proposals.admin.imports.resources.answers", count: count) }
      msg.set(:title) { I18n.t("decidim.proposals.admin.imports.title.answers") }
      msg.set(:label) { I18n.t("decidim.proposals.admin.imports.label.answers") }
      msg.set(:help) { I18n.t("decidim.proposals.admin.imports.help.answers") }
    end

    imports.creator Decidim::Proposals::Import::ProposalAnswerCreator
    imports.example do |import_component|
      organization = import_component.organization
      [
        %w(id state) + organization.available_locales.map { |l| "answer/#{l}" },
        [1, "accepted"] + organization.available_locales.map { "Example answer" },
        [2, "rejected"] + organization.available_locales.map { "Example answer" },
        [3, "evaluating"] + organization.available_locales.map { "Example answer" }
      ]
    end
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    step_settings = if participatory_space.allows_steps?
                      { participatory_space.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true } }
                    else
                      {}
                    end

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name,
      manifest_name: :proposals,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {
        vote_limit: 0,
        collaborative_drafts_enabled: true
      },
      step_settings: step_settings
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    if participatory_space.scope
      scopes = participatory_space.scope.descendants
      global = participatory_space.scope
    else
      scopes = participatory_space.organization.scopes
      global = nil
    end

    5.times do |n|
      state, answer, state_published_at = if n > 3
                                            ["accepted", Decidim::Faker::Localized.sentence(word_count: 10), Time.current]
                                          elsif n > 2
                                            ["rejected", nil, Time.current]
                                          elsif n > 1
                                            ["evaluating", nil, Time.current]
                                          elsif n.positive?
                                            ["accepted", Decidim::Faker::Localized.sentence(word_count: 10), nil]
                                          else
                                            [nil, nil, nil]
                                          end

      params = {
        component: component,
        category: participatory_space.categories.sample,
        scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
        title: { en: Faker::Lorem.sentence(word_count: 2) },
        body: { en: Faker::Lorem.paragraphs(number: 2).join("\n") },
        state: state,
        answer: answer,
        answered_at: state.present? ? Time.current : nil,
        state_published_at: state_published_at,
        published_at: Time.current
      }

      proposal = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Proposals::Proposal,
        admin_user,
        visibility: "all"
      ) do
        proposal = Decidim::Proposals::Proposal.new(params)
        proposal.add_coauthor(participatory_space.organization)
        proposal.save!
        proposal
      end

      if n.positive?
        Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample(n).each do |author|
          user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil
          proposal.add_coauthor(author, user_group: user_group)
        end
      end

      if proposal.state.nil?
        email = "amendment-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-amend#{n}@example.org"
        name = "#{Faker::Name.name} #{participatory_space.id} #{n} amend#{n}"

        author = Decidim::User.find_or_initialize_by(email: email)
        author.update!(
          password: "decidim123456",
          password_confirmation: "decidim123456",
          name: name,
          nickname: Faker::Twitter.unique.screen_name,
          organization: component.organization,
          tos_agreement: "1",
          confirmed_at: Time.current
        )

        group = Decidim::UserGroup.create!(
          name: Faker::Name.name,
          nickname: Faker::Twitter.unique.screen_name,
          email: Faker::Internet.email,
          extended_data: {
            document_number: Faker::Code.isbn,
            phone: Faker::PhoneNumber.phone_number,
            verified_at: Time.current
          },
          decidim_organization_id: component.organization.id,
          confirmed_at: Time.current
        )

        Decidim::UserGroupMembership.create!(
          user: author,
          role: "creator",
          user_group: group
        )

        params = {
          component: component,
          category: participatory_space.categories.sample,
          scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
          title: { en: "#{proposal.title["en"]} #{Faker::Lorem.sentence(word_count: 1)}" },
          body: { en: "#{proposal.body["en"]} #{Faker::Lorem.sentence(word_count: 3)}" },
          state: "evaluating",
          answer: nil,
          answered_at: Time.current,
          published_at: Time.current
        }

        emendation = Decidim.traceability.perform_action!(
          "create",
          Decidim::Proposals::Proposal,
          author,
          visibility: "public-only"
        ) do
          emendation = Decidim::Proposals::Proposal.new(params)
          emendation.add_coauthor(author, user_group: author.user_groups.first)
          emendation.save!
          emendation
        end

        Decidim::Amendment.create!(
          amender: author,
          amendable: proposal,
          emendation: emendation,
          state: "evaluating"
        )
      end

      (n % 3).times do |m|
        email = "vote-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-#{m}@example.org"
        name = "#{Faker::Name.name} #{participatory_space.id} #{n} #{m}"

        author = Decidim::User.find_or_initialize_by(email: email)
        author.update!(
          password: "decidim123456",
          password_confirmation: "decidim123456",
          name: name,
          nickname: Faker::Twitter.unique.screen_name,
          organization: component.organization,
          tos_agreement: "1",
          confirmed_at: Time.current,
          personal_url: Faker::Internet.url,
          about: Faker::Lorem.paragraph(sentence_count: 2)
        )

        Decidim::Proposals::ProposalVote.create!(proposal: proposal, author: author) unless proposal.published_state? && proposal.rejected?
        Decidim::Proposals::ProposalVote.create!(proposal: emendation, author: author) if emendation
      end

      unless proposal.published_state? && proposal.rejected?
        (n * 2).times do |index|
          email = "endorsement-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-endr#{index}@example.org"
          name = "#{Faker::Name.name} #{participatory_space.id} #{n} endr#{index}"

          author = Decidim::User.find_or_initialize_by(email: email)
          author.update!(
            password: "decidim123456",
            password_confirmation: "decidim123456",
            name: name,
            nickname: Faker::Twitter.unique.screen_name,
            organization: component.organization,
            tos_agreement: "1",
            confirmed_at: Time.current
          )
          if index.even?
            group = Decidim::UserGroup.create!(
              name: Faker::Name.name,
              nickname: Faker::Twitter.unique.screen_name,
              email: Faker::Internet.email,
              extended_data: {
                document_number: Faker::Code.isbn,
                phone: Faker::PhoneNumber.phone_number,
                verified_at: Time.current
              },
              decidim_organization_id: component.organization.id,
              confirmed_at: Time.current
            )

            Decidim::UserGroupMembership.create!(
              user: author,
              role: "creator",
              user_group: group
            )
          end
          Decidim::Endorsement.create!(resource: proposal, author: author, user_group: author.user_groups.first)
        end
      end

      (n % 3).times do
        author_admin = Decidim::User.where(organization: component.organization, admin: true).all.sample

        Decidim::Proposals::ProposalNote.create!(
          proposal: proposal,
          author: author_admin,
          body: Faker::Lorem.paragraphs(number: 2).join("\n")
        )
      end

      Decidim::Comments::Seed.comments_for(proposal)

      #
      # Collaborative drafts
      #
      state = if n > 3
                "published"
              elsif n > 2
                "withdrawn"
              else
                "open"
              end
      author = Decidim::User.where(organization: component.organization).all.sample

      draft = Decidim.traceability.perform_action!("create", Decidim::Proposals::CollaborativeDraft, author) do
        draft = Decidim::Proposals::CollaborativeDraft.new(
          component: component,
          category: participatory_space.categories.sample,
          scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
          title: Faker::Lorem.sentence(word_count: 2),
          body: Faker::Lorem.paragraphs(number: 2).join("\n"),
          state: state,
          published_at: Time.current
        )
        draft.coauthorships.build(author: participatory_space.organization)
        draft.save!
        draft
      end

      case n
      when 2
        author2 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author2)
        author3 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author3)
        author4 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author4)
        author5 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author5)
        author6 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author6)
      when 3
        author2 = Decidim::User.where(organization: component.organization).all.sample
        Decidim::Coauthorship.create(coauthorable: draft, author: author2)
      end

      Decidim::Comments::Seed.comments_for(draft)
    end

    Decidim.traceability.update!(
      Decidim::Proposals::CollaborativeDraft.all.sample,
      Decidim::User.where(organization: component.organization).all.sample,
      component: component,
      category: participatory_space.categories.sample,
      scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
      title: Faker::Lorem.sentence(word_count: 2),
      body: Faker::Lorem.paragraphs(number: 2).join("\n")
    )
  end
end
