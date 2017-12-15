# frozen_string_literal: true

class EnablePgExtensions < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pg_trgm"
  rescue
    puts "Can not deal with pg_trgm extension"
  end
end
