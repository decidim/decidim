# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Modify nicknames with random numbers when exists similar ones case insensitively"
    task fix_nickname_uniqueness: :environment do
      logger = Logger.new($stdout)
      logger.info("Updating conflicting user nicknames...")

      # list of users already changed in the process
      has_changed = []

      Decidim::User.not_deleted.find_each do |user|
        next if has_changed.include? user.id

        Decidim::User.where(organization: user.organization)
                     .where("nickname ILIKE ?", user.nickname.downcase)
                     .where.not(id: has_changed + [user.id])
                     .not_deleted
                     .order(:created_at)
                     .each do |similar_user|
          # change her nickname to the lowercased one with numbers if needed
          begin
            update_user_nickname(similar_user, Decidim::UserBaseEntity.nicknamize(similar_user.nickname, organization: similar_user.organization))
          rescue ActiveRecord::RecordInvalid => e
            logger.warn("User ID (#{similar_user.id}) : #{e}")
          end
          has_changed.append(similar_user.id)
        end
      end
      logger.info("Process terminated, #{has_changed.count} users nickname have been updated.")
    end

    private

    def send_notification_to(user)
      Decidim::EventsManager.publish(
        event: "decidim.events.nickname_event",
        event_class: Decidim::ChangeNicknameEvent,
        affected_users: [user],
        resource: user
      )
    end

    def update_user_nickname(user, new_nickname)
      user.update!(nickname: new_nickname)
      send_notification_to(user)
      user
    end
  end
end
