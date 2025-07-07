# frozen_string_literal: true

require "devise/models/api_authenticatable"
require "devise/strategies/api_authenticatable"

Devise.add_module(
  :api_authenticatable,
  model: true,
  strategy: true,
  controller: :sessions,
  route: { session: [nil, :destroy] }
)
