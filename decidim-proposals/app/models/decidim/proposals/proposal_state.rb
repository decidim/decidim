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
        "background-color: #{bg_color}; color: #{text_color}; border-color: #{text_color};"
      end

      def self.colors
        Decidim::Proposals.proposal_states_colors
      end

      protected

      def generate_token
        self.token = ensure_unique_token(token.presence || translated_attribute(title).parameterize(separator: "_"))
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
