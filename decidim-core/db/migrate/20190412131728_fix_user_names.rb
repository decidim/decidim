# frozen_string_literal: true

class FixUserNames < ActiveRecord::Migration[5.2]
  def change
    # Comes from Decidim::User specs
    weird_characters =
      ["<", ">", "?", "\\%", "&", "^", "*", "#", "@", "(", ")", "[", "]", "=", "+", ":", ";", "\"", "{", "}", "\\", "|", "/"]
    characters_to_remove = "<>?%&^*\#@()[]=+:;\"{}\\|/"

    weird_characters.each do |character|
      Decidim::UserBaseEntity.where("name like '%#{character}%' escape '\' OR nickname like '%#{character}%' escape '\'").find_each do |entity|
        Rails.logger.log "detected character: #{character}"
        Rails.logger.log "UserBaseEntity ID: #{entity.id}"
        Rails.logger.log "#{entity.name} => #{entity.name.delete(characters_to_remove).strip}"
        Rails.logger.log "#{entity.nickname} => #{entity.nickname.delete(characters_to_remove).strip}"

        entity.name = entity.name.delete(characters_to_remove).strip
        entity.nickname = entity.nickname.delete(characters_to_remove).strip
        entity.save!
      end
    end
  end
end
