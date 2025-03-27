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
    autoload :ProposalListHelper, "decidim/api/functions/proposal_list_helper"
    autoload :ProposalFinderHelper, "decidim/api/functions/proposal_finder_helper"

    autoload :ProposalSerializer, "decidim/proposals/proposal_serializer"
    autoload :DownloadYourDataProposalSerializer, "decidim/proposals/download_your_data_proposal_serializer"
    autoload :CommentableProposal, "decidim/proposals/commentable_proposal"
    autoload :CommentableCollaborativeDraft, "decidim/proposals/commentable_collaborative_draft"
    autoload :MarkdownToProposals, "decidim/proposals/markdown_to_proposals"
    autoload :ParticipatoryTextSection, "decidim/proposals/participatory_text_section"
    autoload :DocToMarkdown, "decidim/proposals/doc_to_markdown"
    autoload :OdtToMarkdown, "decidim/proposals/odt_to_markdown"
    autoload :Evaluable, "decidim/proposals/evaluable"

    include ActiveSupport::Configurable

    # Public Setting that defines how many proposals will be shown in the
    # participatory_space_highlighted_elements view hook
    config_accessor :participatory_space_highlighted_proposals_limit do
      Decidim::Env.new("PROPOSALS_PARTICIPATORY_SPACE_HIGHLIGHTED_PROPOSALS_LIMIT", 4).to_i
    end

    # Public Setting that defines how many proposals will be shown in the
    # process_group_highlighted_elements view hook
    config_accessor :process_group_highlighted_proposals_limit do
      Decidim::Env.new("PROPOSALS_PROCESS_GROUP_HIGHLIGHTED_PROPOSALS_LIMIT", 3).to_i
    end

    def self.proposal_states_colors
      {
        gray: {
          background: "#F6F8FA",
          foreground: "#4B5058",
          name: I18n.t("gray", scope: "activemodel.attributes.proposal_state.colors")
        },
        blue: {
          background: "#EBF9FF",
          foreground: "#0851A6",
          name: I18n.t("blue", scope: "activemodel.attributes.proposal_state.colors")
        },
        green: {
          background: "#E3FCE9",
          foreground: "#15602C",
          name: I18n.t("green", scope: "activemodel.attributes.proposal_state.colors")
        },
        yellow: {
          background: "#FFFCE5",
          foreground: "#9A6700",
          name: I18n.t("yellow", scope: "activemodel.attributes.proposal_state.colors")
        },
        orange: {
          background: "#FFF1E5",
          foreground: "#BC4C00",
          name: I18n.t("orange", scope: "activemodel.attributes.proposal_state.colors")
        },
        red: {
          background: "#FFEBE9",
          foreground: "#D1242F",
          name: I18n.t("red", scope: "activemodel.attributes.proposal_state.colors")
        },
        pink: {
          background: "#FFEFF7",
          foreground: "#BF3989",
          name: I18n.t("pink", scope: "activemodel.attributes.proposal_state.colors")
        },
        purple: {
          background: "#FBEFFF",
          foreground: "#8250DF",
          name: I18n.t("purple", scope: "activemodel.attributes.proposal_state.colors")
        }
      }
    end

    def self.create_default_states!(component, admin_user, with_traceability: true)
      colors = Decidim::Proposals.proposal_states_colors

      locale = Decidim.default_locale
      default_states = {
        evaluating: {
          token: :evaluating,
          bg_color: colors[:orange][:background],
          text_color: colors[:orange][:foreground],
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_in_evaluation_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:evaluating, scope: "decidim.proposals.answers") } }
        },
        accepted: {
          token: :accepted,
          bg_color: colors[:green][:background],
          text_color: colors[:green][:foreground],
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_accepted_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:accepted, scope: "decidim.proposals.answers") } }
        },
        rejected: {
          token: :rejected,
          bg_color: colors[:red][:background],
          text_color: colors[:red][:foreground],
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_rejected_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:rejected, scope: "decidim.proposals.answers") } }
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
