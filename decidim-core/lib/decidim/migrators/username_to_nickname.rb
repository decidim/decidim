# frozen_string_literal: true

module Decidim
  module Migrators
    class UsernameToNickname
      class User < ApplicationRecord
        self.table_name = :decidim_users
      end

      def migrate!
        User.find_each do |user|
          nickname = user.name.parameterize(separator: "_")[0...20]

          user.update!(nickname: nickname)
        end
      end
    end
  end
end
