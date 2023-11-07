# frozen_string_literal: true

require "decidim/proposals/seeds"
require "decidim/meetings"

Decidim.register_component(:proposals) do |component|
  component.engine = Decidim::Proposals::Engine
  component.admin_engine = Decidim::Proposals::AdminEngine
  component.stylesheet = "decidim/proposals/proposals"
  component.icon = "media/images/decidim_proposals.svg"
  component.icon_key = "chat-new-line"

  component.on(:before_destroy) do |instance|
    raise "Cannot destroy this component when there are proposals" if Decidim::Proposals::Proposal.where(component: instance).any?
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
    settings.attribute :vote_limit, type: :integer, default: 0, required: true
    settings.attribute :minimum_votes_per_user, type: :integer, default: 0, required: true
    settings.attribute :proposal_limit, type: :integer, default: 0, required: true
    settings.attribute :proposal_length, type: :integer, default: 500
    settings.attribute :proposal_edit_time, type: :enum, default: "limited", choices: -> { %w(limited infinite) }
    settings.attribute :proposal_edit_before_minutes, type: :integer, default: 5, required: true
    settings.attribute :threshold_per_proposal, type: :integer, default: 0, required: true
    settings.attribute :can_accumulate_supports_beyond_threshold, type: :boolean, default: false
    settings.attribute :proposal_answering_enabled, type: :boolean, default: true
    settings.attribute :default_sort_order, type: :select, default: "default", choices: -> { POSSIBLE_SORT_ORDERS }
    settings.attribute :official_proposals_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
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
    settings.attribute :new_proposal_body_template,
                       type: :text, translated: true,
                       editor: ->(context) { context[:component].organization.rich_text_editor_in_public_views },
                       required: false
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
                   .not_hidden
                   .where(component: component_instance)
                   .includes(:scope, :category, :component)

      if space.user_roles(:valuator).where(user:).any?
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
      msg.set(:resource_name) { |count: 1| I18n.t("decidim.proposals.admin.imports.resources.proposals", count:) }
      msg.set(:title) { I18n.t("decidim.proposals.admin.imports.title.proposals") }
      msg.set(:label) { I18n.t("decidim.proposals.admin.imports.label.proposals") }
      msg.set(:help) { I18n.t("decidim.proposals.admin.imports.help.proposals") }
    end

    imports.creator Decidim::Proposals::Import::ProposalCreator
  end

  component.imports :answers do |imports|
    imports.messages do |msg|
      msg.set(:resource_name) { |count: 1| I18n.t("decidim.proposals.admin.imports.resources.answers", count:) }
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
    Decidim::Proposals::Seeds.new(participatory_space:).call
  end
end
