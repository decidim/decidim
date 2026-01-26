# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Delete follows of members deleted from a restricted space"
    task fix_deleted_members_follows: :environment do
      Decidim::Organization.all.each do |organization|
        spaces = organization.participatory_spaces.collect { |space| space if space.respond_to?(:restricted?) && space.restricted? }.compact_blank

        next if spaces.blank?

        spaces = spaces.map { |space| space.respond_to?(:transparent?) ? (space unless space.transparent?) : space }.compact_blank

        next if spaces.blank?

        organization.users.find_each do |user|
          next unless user.following_follows.count.positive?

          spaces.each do |space|
            Decidim::Admin::ParticipatorySpace::DestroyMembersFollowsJob.perform_later(user, space)
          end
        end
      end
    end
  end
end
