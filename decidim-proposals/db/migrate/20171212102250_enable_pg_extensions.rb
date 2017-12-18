# frozen_string_literal: true

class EnablePgExtensions < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pg_trgm"
  end
end
