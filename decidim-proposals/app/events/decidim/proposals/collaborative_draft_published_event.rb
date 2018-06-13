# frozen-string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraftPublishedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent
      i18n_attributes :author_nickname, :author_name, :author_path

      delegate :nickname, :name, to: :author, prefix: true

      delegate :nickname, to: :author, prefix: true

      def author_path
        author.profile_path
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
