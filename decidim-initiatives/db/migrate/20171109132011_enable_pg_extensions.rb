# frozen_string_literal: true

class EnablePgExtensions < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pg_trgm"
  rescue ActiveRecord::CatchAll => e
    puts "Can not deal with pg_trgm extension: #{e}"
  end
end
