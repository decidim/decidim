# frozen_string_literal: true

module Decidim
  module Migrators
    class UsernameToNickname
      class User < ApplicationRecord
        extend Decidim::Nicknamizable

        self.table_name = :decidim_users
      end

      def migrate!
        User.find_each do |user|
          user.update!(nickname: User.nicknamize(user.name))
        end
      end
    end
  end
end
