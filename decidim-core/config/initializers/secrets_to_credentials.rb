# frozen_string_literal: true

source = ERB.new(Rails.root.join("config/secrets.yml").read).result
secrets = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(source) : YAML.load(source)
Rails.application.credentials.deep_merge!(secrets[Rails.env].deep_symbolize_keys)
