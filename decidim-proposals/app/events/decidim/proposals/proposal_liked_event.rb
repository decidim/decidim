# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalLikedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :liker_nickname, :liker_name, :liker_path, :nickname

      delegate :nickname, :name, to: :liker, prefix: true

      def nickname
        liker_nickname
      end

      def liker_path
        liker.profile_path
      end

      def resource_text
        resource.body
      end

      private

      def liker
        @liker ||= Decidim::UserPresenter.new(liker_user)
      end

      def liker_user
        @liker_user ||= Decidim::User.find_by(id: extra[:liker_id])
      end
    end
  end
end
