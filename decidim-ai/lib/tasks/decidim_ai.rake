# frozen_string_literal: true

namespace :decidim do
  namespace :ai do
    desc "Create reporting user"
    task create_reporting_user: :environment do
      Decidim::Ai.create_reporting_users!
    end

    desc "Load plugin shipped datasets"
    task load_plugin_dataset: :environment do
      Dir.glob("#{plugin_path}/data/*.csv").each do |file|
        Decidim::Ai::SpamDetection::Importer::File.call(file)
      end
    end

    desc "Load application datasets"
    task :load_application_dataset, [:file] => :environment do |_, args|
      Decidim::Ai::SpamDetection::Importer::File.call(args[:file])
    end

    private

    def plugin_path
      Gem.loaded_specs["decidim-ai"].full_gem_path
    end
  end
end
