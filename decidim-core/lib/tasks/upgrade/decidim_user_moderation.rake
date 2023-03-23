# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    namespace :moderation do
      desc "Add all blocked users to global moderation panel"
      task fix_blocked_user_panel: :environment do
        Decidim::UserBlock.find_each do |blocked_user|
          Decidim::UserModeration.where(user: blocked_user.user).first_or_create!
        end
      end
    end
  end
end
