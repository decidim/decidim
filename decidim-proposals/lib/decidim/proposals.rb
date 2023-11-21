# frozen_string_literal: true

require "decidim/proposals/admin"
require "decidim/proposals/api"
require "decidim/proposals/engine"
require "decidim/proposals/admin_engine"
require "decidim/proposals/import"
require "decidim/proposals/component"

module Decidim
  # This namespace holds the logic of the `Proposals` component. This component
  # allows users to create proposals in a participatory process.
  module Proposals
    autoload :ProposalSerializer, "decidim/proposals/proposal_serializer"
    autoload :CommentableProposal, "decidim/proposals/commentable_proposal"
    autoload :CommentableCollaborativeDraft, "decidim/proposals/commentable_collaborative_draft"
    autoload :MarkdownToProposals, "decidim/proposals/markdown_to_proposals"
    autoload :ParticipatoryTextSection, "decidim/proposals/participatory_text_section"
    autoload :DocToMarkdown, "decidim/proposals/doc_to_markdown"
    autoload :OdtToMarkdown, "decidim/proposals/odt_to_markdown"
    autoload :Valuatable, "decidim/proposals/valuatable"

    include ActiveSupport::Configurable

    # Public Setting that defines the similarity minimum value to consider two
    # proposals similar. Defaults to 0.25.
    config_accessor :similarity_threshold do
      0.25
    end

    # Public Setting that defines how many similar proposals will be shown.
    # Defaults to 10.
    config_accessor :similarity_limit do
      10
    end

    # Public Setting that defines how many proposals will be shown in the
    # participatory_space_highlighted_elements view hook
    config_accessor :participatory_space_highlighted_proposals_limit do
      4
    end

    # Public Setting that defines how many proposals will be shown in the
    # process_group_highlighted_elements view hook
    config_accessor :process_group_highlighted_proposals_limit do
      3
    end

    def self.create_default_states!(component, admin_user, with_traceability: true)
      locale = Decidim.default_locale
      default_states = {
        not_answered: {
          token: :not_answered,
          css_class: "info",
          default: true,
          include_in_stats: {},
          system: true,
          answerable: false,
          notifiable: false,
          title: { locale => I18n.with_locale(locale) { I18n.t(:not_answered, scope: "decidim.proposals.answers") } }
        },
        evaluating: {
          token: :evaluating,
          css_class: "warning",
          default: false,
          include_in_stats: {},
          answerable: true,
          system: true,
          notifiable: true,
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_in_evaluation_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:evaluating, scope: "decidim.proposals.answers") } }
        },
        accepted: {
          token: :accepted,
          css_class: "success",
          default: false,
          include_in_stats: {},
          answerable: true,
          notifiable: true,
          system: true,
          gamified: true,
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_accepted_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:accepted, scope: "decidim.proposals.answers") } }
        },
        rejected: {
          token: :rejected,
          css_class: "alert",
          default: false,
          include_in_stats: {},
          answerable: true,
          notifiable: true,
          system: true,
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_rejected_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:rejected, scope: "decidim.proposals.answers") } }
        },
        withdrawn: {
          token: :withdrawn,
          css_class: "alert",
          default: false,
          include_in_stats: {},
          system: true,
          answerable: false,
          notifiable: false,
          title: { locale => I18n.with_locale(locale) { I18n.t(:withdrawn, scope: "decidim.proposals.answers") } }
        }
      }
      default_states.each_key do |key|
        default_states[key][:object] = if with_traceability
                                         Decidim.traceability.create(
                                           Decidim::Proposals::ProposalState, admin_user, component:, **default_states[key]
                                         )
                                       else
                                         Decidim::Proposals::ProposalState.create(component:, **default_states[key])
                                       end
      end
      default_states
    end
  end

  module ContentParsers
    autoload :ProposalParser, "decidim/content_parsers/proposal_parser"
  end

  module ContentRenderers
    autoload :ProposalRenderer, "decidim/content_renderers/proposal_renderer"
  end
end
