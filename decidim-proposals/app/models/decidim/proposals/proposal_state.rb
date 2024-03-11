# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalState < Proposals::ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable

      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes

      before_validation :generate_token, on: :create

      translatable_fields :title

      validates :token, presence: true, uniqueness: { scope: :component }

      has_many :proposals,
               class_name: "Decidim::Proposals::Proposal",
               foreign_key: "decidim_proposals_proposal_state_id",
               inverse_of: :proposal_state,
               dependent: :restrict_with_error,
               counter_cache: :proposals_count

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::ProposalStatePresenter
      end

      def css_style
        "background-color: #{bg_color}; color: #{text_color};"
      end

      def self.colors
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

      protected

      def generate_token
        self.token = ensure_unique_token(translated_attribute(title).parameterize(separator: "_"))
      end

      def ensure_unique_token(token)
        step = 0
        code = token
        loop do
          break if Decidim::Proposals::ProposalState.where(component:, token: code).empty?

          code = "#{token}_#{step}"
          step += 1
        end

        code
      end
    end
  end
end
