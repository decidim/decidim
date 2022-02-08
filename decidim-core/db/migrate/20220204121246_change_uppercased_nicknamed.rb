# frozen_string_literal: true

class ChangeUppercasedNicknamed < ActiveRecord::Migration[6.0]
  def up
    # list of users already changed in the process
    has_changed = []
    Decidim::User.find_each do |user|
      next if has_changed.include? user
      # if already downcased, don't care
      next if user.nickname.downcase == user.nickname

      Decidim::User.where("nickname ILIKE ?", user.nickname.downcase).order(:created_at).each_with_index do |similar_user,index|
        next if has_changed.include? similar_user

        # change his nickname to the lowercased one with -1 if it's the first, -2 if it's the second etc
        similar_user.nickname.update!("#{similar_user.nickname.downcase}-#{index+1}")
        has_changed.append(similar_user)
      end

      user.nickname.update!(user.nickname.downcase)
      has_changed.append(user)
    end
  end
end
