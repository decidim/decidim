# frozen_string_literal: true

class ChangeUppercasedNicknamed < ActiveRecord::Migration[6.0]
  def up
    # list of users already changed in the process
    has_changed = []
    Decidim::User.find_each do |user1|
      next if has_changed.include? user1
      # if already downcased, don't care
      next if user1.nickname.downcase == user1.nickname

      i = 1
      Decidim::User.where("nickname ILIKE ?", user1.nickname.downcase).order(:created_at).each do |user2|
        next if has_changed.include? user2

        # change his nickname to the lowercased one with -1 if it's the first, -2 if it's the second etc
        user2.nickname = "#{user2.nickname.downcase}-#{i}"
        user2.save!
        has_changed.append(user2)
        i += 1
      end

      user1.nickname = user1.nickname.downcase
      user1.save!
      has_changed.append(user1)
    end
  end
end
