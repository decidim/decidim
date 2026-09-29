# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Fix inconsistencies between followers badge scores and actual follower counts"
    task align_followers_badge_scores: :environment do
      puts "Recalculating :followers badge scores from users followers data..."

      fixed_count = 0
      skipped_count = 0

      Decidim::Gamification::BadgeScore.where(badge_name: "followers").find_each do |badge_score|
        user_id = badge_score.user_id

        real_count = Decidim::Follow.where(
          decidim_followable_type: "Decidim::UserBaseEntity",
          decidim_followable_id: user_id
        ).count

        if badge_score.value == real_count
          skipped_count += 1
          next
        else
          badge_score.update!(value: real_count)

          user = Decidim::User.find(user_id)
          Decidim::Gamification.set_score(user, :followers, real_count)

          fixed_count += 1
        end
      end

      puts "Followers badge scores fix complete."
      puts "Fixed: #{fixed_count}"
      puts "Skipped: #{skipped_count}"
    end
  end
end
