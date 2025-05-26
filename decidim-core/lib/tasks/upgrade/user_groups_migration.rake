# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    namespace :user_groups do
      desc "Main task to notify users and change references to groups"
      task remove: [
        :"decidim:upgrade:user_groups:send_reset_password_instructions",
        :"decidim:upgrade:user_groups:send_user_group_changes_notification_to_members",
        :"decidim:upgrade:user_groups:transfer_user_groups_authorships",
        :"decidim:upgrade:user_groups:fix_user_groups_action_logs",
        :"decidim:upgrade:user_groups:remove_groups_notifications"
      ]

      desc "Send reset password instructions to groups"
      task send_reset_password_instructions: :environment do
        Decidim::User.user_group.where(encrypted_password: "").find_each do |group|
          Decidim::UserGroupMailer.notify_deprecation_to_owner(group).deliver_later
        end
      end

      desc "Notify user group changes to members"
      task send_user_group_changes_notification_to_members: :environment do
        class UserGroupMembership < ApplicationRecord
          self.table_name = "decidim_user_group_memberships"

          belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
          belongs_to :group, class_name: "Decidim::User", foreign_key: :decidim_user_group_id

          scope :member, -> { where(role: %w(creator admin member)) }
        end

        Decidim::User.user_group.where(encrypted_password: "").find_each do |group|
          UserGroupMembership.where(group:).member.find_each do |membership|
            user = membership.user
            next if user.deleted? || user.blocked? || !user.confirmed?

            Decidim::UserGroupMailer
              .notify_deprecation_to_member(
                user,
                group.name,
                group.email
              ).deliver_later
          end
        end
      end

      desc "Transfer user groups authorships"
      task transfer_user_groups_authorships: :environment do
        coauthorable_models = %w(
          Decidim::Proposals::Proposal
          Decidim::Proposals::CollaborativeDraft
        )
        authorable_models = %w(
          Decidim::Like
          Decidim::Initiative
          Decidim::Blogs::Post
          Decidim::Comments::Comment
          Decidim::Debates::Debate
          Decidim::Meetings::Meeting
        )

        authorships = []
        authorable_models.map(&:safe_constantize).compact.each do |model|
          model.find_each do |item|
            next unless item.decidim_user_group_id&.positive?
            next unless Decidim::User.exists?(item.decidim_user_group_id)

            authorships << {
              item:,
              gid: item.to_gid,
              model: model.name,
              id: item.id,
              author_type: item.decidim_author_type,
              author_id: item.decidim_author_id,
              group_id: item.decidim_user_group_id
            }
          end
        end

        Decidim::Coauthorship.where(coauthorable_type: coauthorable_models).find_each do |item|
          next unless item.decidim_user_group_id&.positive?
          next unless Decidim::User.exists?(item.decidim_user_group_id)

          authorships << {
            item:,
            gid: item.to_gid,
            model: item.coauthorable_type,
            id: item.id,
            author_type: item.decidim_author_type,
            author_id: item.decidim_author_id,
            group_id: item.decidim_user_group_id
          }
        end

        puts "===== Transferring #{authorships.count} authorships..."
        authorships.each do |a|
          item = a[:item]

          # rubocop:disable Rails/SkipsModelValidations
          item.update_attribute(:decidim_author_type, "Decidim::UserBaseEntity") if item.decidim_author_type != "Decidim::UserBaseEntity"
          item.update_attribute(:decidim_author_id, a[:group_id])
          item.update_attribute(:decidim_user_group_id, a[:author_id])
          # rubocop:enable Rails/SkipsModelValidations

          puts "Transferred authorship in #{a[:model]} with id #{a[:id]} and gid #{a[:gid]} from #{a[:author_type]} with id #{a[:author_id]} to user with id #{a[:group_id]}"
        end
        puts "===== Transfer finished."
      end

      desc "Transform action log entries related with user groups to user"
      task fix_user_groups_action_logs: :environment do
        items = Decidim::ActionLog.where(resource_type: "Decidim::UserGroup")

        if (count = items.count).positive?
          # rubocop:disable Rails/SkipsModelValidations
          items.update_all(resource_type: "Decidim::User")
          # rubocop:enable Rails/SkipsModelValidations

          puts "===== Transformed #{count} action log entries."
        else
          puts "===== Skipped, no entries found to transform."
        end
      end

      desc "Remove notification entries related with user groups"
      task remove_groups_notifications: :environment do
        items = Decidim::Notification.where(
          event_class: %w(
            Decidim::Comments::CommentByFollowedUserGroupEvent
            Decidim::Comments::UserGroupMentionedEvent
            Decidim::DemotedMembershipEvent
            Decidim::InvitedToGroupEvent
            Decidim::JoinRequestAcceptedEvent
            Decidim::JoinRequestCreatedEvent
            Decidim::JoinRequestRejectedEvent
            Decidim::PromotedToAdminEvent
            Decidim::RemovedFromGroupEvent
            Decidim::UserGroupAdminEvent
            Decidim::UserGroupCreatedEvent
            Decidim::UserGroupUpdatedEvent
          )
        )

        if (count = items.count).positive?
          items.find_each(&:destroy)

          puts "===== Removed #{count} action log entries."
        else
          puts "===== Skipped, no entries found to remove."
        end
      end
    end
  end
end
