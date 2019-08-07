# frozen-string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraftAccessRequestEvent < Decidim::Events::SimpleEvent
      i18n_attributes :requester_name, :requester_path, :requester_nickname

      delegate :name, to: :requester, prefix: true

      delegate :nickname, to: :requester, prefix: true

      def requester_path
        requester.profile_path
      end

      private

      def requester
        @requester ||= Decidim::UserPresenter.new(rejected_requester_user)
      end

      def rejected_requester_user
        @rejected_requester_user ||= Decidim::User.find_by(id: extra[:requester_id])
      end
    end
  end
end
