# frozen_string_literal: true

module Decidim
  module Migrators
    class UsernameToNickname
      class User < ApplicationRecord
        self.table_name = :decidim_users
      end

      def migrate!
        User.find_each do |user|
          user.update!(nickname: user.name)
        end
      end
    end
  end
end
