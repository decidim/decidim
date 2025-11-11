# frozen_string_literal: true

require "shakapacker/env"

module Shakapacker
  class Env
    def current
      puts "*" * 80
      puts config_path.to_s
      puts File.exist?(config_path.to_s)
      puts number_of_lines_in_config
      if number_of_lines_in_config == 0
        create_config_file
      end
      puts number_of_lines_in_config
      # puts YAML.load_file(config_path.to_s, aliases: true).inspect

      env = Rails&.env&.present? ? Rails.env : (ENV["RAILS_ENV"] || "test")
      puts env
      puts "*" * 80

      envs = available_environments || {}
      env.presence_in(envs) || env
    end

    private

    def number_of_lines_in_config
      File.read(config_path.to_s).split.count
    end

    def create_config_file
      runtime = Rails.application.root.join("tmp/shakapacker_runtime.yml")
      FileUtils.mkdir_p(File.dirname(runtime))
      File.write(runtime, <<~YAML)
        default:
          source_path: app/packs
          public_output_path: packs-test
          additional_paths: []
        test:
          <<: *default
      YAML
    end
  end
end

class Shakapacker::Configuration
  def load
    config = begin
      YAML.load_file(config_path.to_s, aliases: true)
    rescue ArgumentError
      YAML.load_file(config_path.to_s)
    end

    puts "=" * 80
    puts config_path.to_s
    puts File.exist?(config_path.to_s)
    puts File.read(config_path.to_s).split.count

    puts "===> Shakapacker env: #{env.inspect}"
    puts "===> Shakapacker YAML top-level keys: #{config.keys.inspect}"

    symbolized_config = config[env].deep_symbolize_keys

    return symbolized_config
  rescue Errno::ENOENT => e
    if self.class.installing
      {}
    else
      raise "Shakapacker configuration file not found #{config_path}. " \
            "Please run rails shakapacker:install " \
            "Error: #{e.message}"
    end
  rescue Psych::SyntaxError => e
    raise "YAML syntax error occurred while parsing #{config_path}. " \
          "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
          "Error: #{e.message}"
  end
end
