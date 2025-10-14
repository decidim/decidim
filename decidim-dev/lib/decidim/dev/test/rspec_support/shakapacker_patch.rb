# frozen_string_literal: true

require "shakapacker/env"

module Shakapacker
  class Env
    def current
      envs = available_environments || {}
      Rails.env.presence_in(envs) || Shakapacker::DEFAULT_ENV
    end
  end
end
