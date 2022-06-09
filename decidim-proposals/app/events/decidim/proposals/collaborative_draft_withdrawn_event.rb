# frozen-string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraftWithdrawnEvent < Decidim::Events::SimpleEvent
      i18n_attributes :author_nickname, :author_name, :author_path, :author_url

      delegate :nickname, :name, to: :author, prefix: true

      def nickname
        author_nickname
      end

      def author_path
        author.profile_path
      end

      def author_url
        author.profile_url
      end

      private

      def author
        @author ||= Decidim::UserPresenter.new(author_user)
      end

      def author_user
        @author_user ||= Decidim::User.find_by(id: extra[:author_id])
      end
    end
  end
end
