# frozen_string_literal: true
require "byebug"

namespace :decidim do
  namespace :redesign do
    desc "Copies entrypoint file to redesigned and updates webpacker configuration"
    task :redesign_entrypoint, [:path] do |_t, args|
      path = args[:path]
      destination_path = path.sub(%r{.*\K/}, "/redesigned_")
      module_name = path.split("/").first
      raise "Invalid module. Path starts with #{module_name} which is not a valid module or design app" unless module_name.start_with?("decidim-", "decidim_app-design")

      FileUtils.cp(path, destination_path)

      assets_config_path = "#{module_name}/config/assets.rb"
      old_entrypoint = path.sub(%r{\A#{module_name}/}, "")
      new_entrypoint = destination_path.sub(%r{\A#{module_name}/}, "")

      Decidim::GemManager.replace_file(
        assets_config_path,
        /^(\s*)(\S*):\s*\"\#\{base_path\}\/#{old_entrypoint}\"(,?)/,
        "\\1\\2: \"\#\{base_path\}\/#{old_entrypoint}\",\n\\1redesigned_\\2: \"\#\{base_path\}\/#{new_entrypoint}\"\\3"
      )
    end
  end
end
