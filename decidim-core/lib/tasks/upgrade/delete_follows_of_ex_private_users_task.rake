# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Delete follows of ex private users"
    task fix_deleted_private_follows: :environment do
      Decidim::Organization.all.each do |organization|
        spaces = organization.participatory_spaces.collect { |space| space if space.respond_to?(:private_space?) && space.private_space? }.compact_blank

        next if spaces.blank?

        spaces = spaces.map { |space| space.respond_to?(:is_transparent?) ? (space unless space.is_transparent?) : space }.compact_blank

        next if spaces.blank?

        organization.users.find_each do |user|
          next unless user.following_follows.count.positive?

          spaces.each do |space|
            Decidim::Admin::DestroyPrivateUsersFollowsJob.perform_later(user, space)
          end
        end
      end
    end
  end
end
