# frozen_string_literal: true

class RenameSendToMembersInNewsletter < ActiveRecord::Migration[8.1]
  class Newsletter < ApplicationRecord
    self.table_name = :decidim_newsletters
  end

  def up
    Newsletter.find_each do |newsletter|
      next unless newsletter.extended_data
      next unless newsletter.extended_data.has_key?("send_to_private_members")

      newsletter.extended_data["send_to_members"] = newsletter.extended_data.delete("send_to_private_members")
      newsletter.save!(validate: false)
    end
  end

  def down
    Newsletter.find_each do |newsletter|
      next unless newsletter.extended_data
      next unless newsletter.extended_data.has_key?("send_to_members")

      newsletter.extended_data["send_to_private_members"] = newsletter.extended_data.delete("send_to_members")
      newsletter.save!(validate: false)
    end
  end
end
