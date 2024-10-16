# frozen_string_literal: true

namespace :decidim do
  namespace :ai do
    namespace :spam do
      desc "Create reporting user"
      task create_reporting_user: :environment do
        Decidim::Ai::SpamDetection.create_reporting_user!
      end

      desc "Load application dataset file"
      task :load_application_dataset, [:file] => :environment do |_, args|
        Decidim::Ai::SpamDetection::Importer::File.call(args[:file], Decidim::Ai::SpamDetection.user_classifier)
        Decidim::Ai::SpamDetection::Importer::File.call(args[:file], Decidim::Ai::SpamDetection.resource_classifier)
      end

      desc "Train model using application database"
      task train_application_database: :environment do
        Decidim::Ai::SpamDetection::Importer::Database.call
      end

      desc "Reset all training model"
      task reset: :environment do
        Decidim::Ai::SpamDetection.user_classifier.reset
        Decidim::Ai::SpamDetection.resource_classifier.reset
      end

      private

      def plugin_path
        Gem.loaded_specs["decidim-ai"].full_gem_path
      end
    end
  end
end
