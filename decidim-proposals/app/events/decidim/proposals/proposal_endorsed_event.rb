# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalEndorsedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :endorser_nickname, :endorser_name, :endorser_path

      delegate :nickname, :name, to: :endorser, prefix: true

      def endorser_path
        endorser.profile_path
      end

      private

      def endorser
        @endorser ||= Decidim::UserPresenter.new(extra[:endorser])
      end
    end
  end
end
