# frozen_string_literal: true

namespace :decidim do
  namespace :redesign do
    desc "Copies entrypoint file to redesigned and updates webpacker configuration"
    task :redesign_entrypoint, [:path] do |_t, args|
      path = args[:path]
      destination_path = path.sub(%r{.*\K/}, "/redesigned_")
      module_name = path.split("/").first
      extension = path.split(".").last
      raise "Invalid module. Path starts with #{module_name} which is not a valid module or design app" unless module_name.start_with?("decidim-", "decidim_app-design")

      FileUtils.cp(path, destination_path)

      assets_config_path = "#{module_name}/config/assets.rb"
      case extension
      when "js"
        old_entrypoint = path.sub(%r{\A#{module_name}/}, "")
        new_entrypoint = destination_path.sub(%r{\A#{module_name}/}, "")
        register_redesigned_js_entrypoint(assets_config_path, old_entrypoint, new_entrypoint)
      when "scss"
        entrypoint = path.sub(%r{\A#{module_name}/app/packs/}, "").sub(/\.#{extension}\z/, "")
        register_redesigned_scss_entrypoint(assets_config_path, entrypoint)
      end
    end
  end
end

def register_redesigned_js_entrypoint(assets_config_path, old_entrypoint, new_entrypoint)
  Decidim::GemManager.replace_file(
    assets_config_path,
    %r{^(\s*)(\S*):\s*"\#\{base_path\}/#{old_entrypoint}"(,?)},
    "\\1\\2: \"\#\{base_path\}\/#{old_entrypoint}\",\n\\1redesigned_\\2: \"\#\{base_path\}\/#{new_entrypoint}\"\\3"
  )
end

def register_redesigned_scss_entrypoint(assets_config_path, entrypoint)
  Decidim::GemManager.replace_file(
    assets_config_path,
    /^(Decidim::Webpacker.register_stylesheet_import\("#{entrypoint}"\))/,
    "\\1\nDecidim::Webpacker.register_redesigned_stylesheet_import(\"#{entrypoint}\")"
  )
end
