# frozen_string_literal: true

module Decidim
  module Migrators
    class UsernameToNickname
      class User < ApplicationRecord
        self.table_name = :decidim_users
      end

      def migrate!
        User.find_each do |user|
          nickname = disambiguate(user.name.parameterize(separator: "_")[0...20])

          user.update!(nickname: nickname)
        end
      end

      private

      def disambiguate(nickname)
        candidate = nickname

        2.step do |n|
          return candidate unless User.exists?(nickname: candidate)

          candidate = "#{candidate}_#{n}"
        end
      end
    end
  end
end
