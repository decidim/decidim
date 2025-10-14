# frozen_string_literal: true

require "shakapacker/env"

module Shakapacker
  class Env
    def current
      puts config_path.to_s
      puts File.exist?(config_path.to_s)
      puts File.read(config_path.to_s)

      envs = available_environments || {}
      Rails.env.presence_in(envs) || Shakapacker::DEFAULT_ENV
    end
  end
end
