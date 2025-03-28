# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Modifies nickname of the user to lower case"
    task :fix_nickname_casing => :environment do
      logger.info("Fixing user nicknames case...")

      has_changed = []
      Decidim::UserBaseEntity.not_deleted.find_each do |user|
        user.nickname.downcase!

        begin
          if user.nickname_changed?
            user.save!
            has_changed << user.id
          end
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
          update_user_nickname(user, Decidim::UserBaseEntity.nicknamize(user.nickname, organization: user.organization))
          has_changed << user.id
        rescue ActiveRecord::RecordInvalid # rubocop:disable Lint/DuplicateRescueException
          logger.warn("User ID (#{user.id}) : #{e}")
        end
      end
      logger.info("Process terminated, #{has_changed.count} users nickname have been updated.")
    end

    desc "Modifies nicknames with random numbers when exists similar ones case-insensitively"
    task :fix_nickname_uniqueness => :environment do
      Rake::Task["decidim:upgrade:fix_nickname_casing"].execute
    end

    private

    def logger
      @logger ||= Logger.new($stdout)
    end

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
