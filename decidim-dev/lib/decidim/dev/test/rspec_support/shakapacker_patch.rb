# frozen_string_literal: true

require "shakapacker/env"

module Shakapacker
  class Env
    def current
      puts "*" * 80
      puts config_path.to_s
      puts File.exist?(config_path.to_s)
      puts File.read(config_path.to_s).split.count
      # puts YAML.load_file(config_path.to_s, aliases: true).inspect
      puts "*" * 80

      env = Rails&.env&.present? ? Rails.env : (ENV["RAILS_ENV"] || "test")

      envs = available_environments || {}
      env.presence_in(envs) || env
    end
  end
end
