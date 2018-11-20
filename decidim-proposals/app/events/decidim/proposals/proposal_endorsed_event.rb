# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalEndorsedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :endorser_nickname, :endorser_name, :endorser_path, :nickname

      delegate :nickname, :name, to: :endorser, prefix: true

      def nickname
        endorser_nickname
      end

      def endorser_path
        endorser.profile_path
      end

      def resource_text
        resource.body
      end

      private

      def endorser
        @endorser ||= Decidim::UserPresenter.new(endorser_user)
      end

      def endorser_user
        @endorser_user ||= Decidim::User.find_by(id: extra[:endorser_id])
      end
    end
  end
end
