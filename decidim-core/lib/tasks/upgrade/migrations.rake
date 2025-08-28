# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Replace legacy migration content"
    task migrations: :environment do
      available_modules = {
        "accountability" => "Accountability",
        "admin" => "Admin",
        "ai" => "Ai",
        "api" => "Api",
        "assemblies" => "Assemblies",
        "blogs" => "Blogs",
        "budgets" => "Budgets",
        "comments" => "Comments",
        "conferences" => "Conferences",
        "core" => "Core",
        "debates" => "Debates",
        "design" => "Design",
        "dev" => "Dev",
        "forms" => "Forms",
        "initiatives" => "Initiatives",
        "meetings" => "Meetings",
        "pages" => "Pages",
        "participatory_processes" => "ParticipatoryProcesses",
        "proposals" => "Proposals",
        "sortitions" => "Sortitions",
        "surveys" => "Surveys",
        "system" => "System",
        "templates" => "Templates",
        "verifications" => "Verifications"
      }

      available_modules.each do |key, value|
        next unless Decidim.module_installed?(key.to_sym)

        migration_files = Dir["Decidim::#{value}::Engine".constantize.root.join("db/migrate/*.rb")]
        next if migration_files.blank?

        migration_files.each do |file|
          next if file.include?("active_storage")

          replace_content(file)
        end
      end
    end

    private

    def replace_content(file_path)
      migration_file = File.basename(file_path)
      version = migration_file.split("_").first
      migration_file_base = migration_file.gsub!(/^\d+_/, "").gsub!(/\.rb$/, "")

      target_file = Rails.root.glob("db/migrate/**_#{migration_file_base}.*.rb").first
      return if target_file.blank?

      scope = target_file.to_s.split(".")[-2]

      source = File.binread(file_path)

      # This has been extracted from activerecord file lib/active_record/migration.rb
      inserted_comment = "# This migration comes from #{scope} (originally #{version})\n"
      magic_comments = +""
      loop do
        source.sub!(/\A(?:#.*\b(?:en)?coding:\s*\S+|#\s*frozen_string_literal:\s*(?:true|false)).*\n/) do |magic_comment|
          magic_comments << magic_comment
          ""
        end || break
      end

      if !magic_comments.empty? && source.start_with?("\n")
        magic_comments << "\n"
        source = source[1..-1]
      end

      new_source = "#{magic_comments}#{inserted_comment}#{source}"

      old_source = File.binread(target_file)
      old_source = old_source.gsub(/# This file has been modified by `decidim upgrade:migrations` task on (.*)\n/, "")

      return if old_source == new_source

      logger.warn("[Patch migration] Replacing content of #{File.basename(target_file)}")

      additional_comment = "# This file has been modified by `decidim upgrade:migrations` task on #{Time.now.utc}\n"
      source = new_source.gsub(inserted_comment, "#{inserted_comment}#{additional_comment}")

      File.binwrite(target_file, source)
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
