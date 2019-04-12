# frozen_string_literal: true

class FixUserNames < ActiveRecord::Migration[5.2]
  def change
    # Comes from Decidim::User specs
    weird_characters =
      ["<", ">", "?", "\\%", "&", "^", "*", "#", "@", "(", ")", "[", "]", "=", "+", ":", ";", "\"", "{", "}", "\\", "|"]
    characters_to_remove = "<>?%&^*\#@()[]=+:;\"{}\\|"

    weird_characters.each do |character|
      Decidim::UserBaseEntity.where("name like '%#{character}%' escape '\'").find_each do |entity|
        p "detected character: #{character}"
        p "UserBaseEntity ID: #{entity.id}"
        p "#{entity.name} => #{entity.name.delete(characters_to_remove).strip}"
        p "#{entity.nickname} => #{entity.nickname.delete(characters_to_remove).strip}"

        entity.name = entity.name.delete(characters_to_remove).strip
        entity.nickname = entity.nickname.delete(characters_to_remove).strip
        entity.save!
      end
    end
  end
end
