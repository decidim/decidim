# frozen-string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraftAccessRejectedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :requester_nickname, :requester_name, :requester_path, :nickname

      delegate :nickname, :name, to: :requester, prefix: true

      def nickname
        requester_nickname
      end

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
