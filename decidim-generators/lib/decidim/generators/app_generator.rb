# frozen_string_literal: true

require "bundler"
require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/generators"
require_relative "install_generator"

module Decidim
  module Generators
    # Generates a Rails app and installs decidim to it. Uses the default Rails
    # generator for most of the work.
    #
    # Remember that, for how generators work, actions are executed based on the
    # definition order of the public methods.
    class AppGenerator < Rails::Generators::AppGenerator
      hide!

      def source_paths
        [
          self.class.source_root,
          Rails::Generators::AppGenerator.source_root
        ]
      end

      source_root File.expand_path("app_templates", __dir__)

      class_option :app_name, type: :string,
                              default: nil,
                              desc: "The name of the app"

      class_option :path, type: :string,
                          default: nil,
                          desc: "Path to the gem"

      class_option :edge, type: :boolean,
                          default: false,
                          desc: "Use GitHub's edge version from develop branch"

      class_option :branch, type: :string,
                            default: nil,
                            desc: "Use a specific branch from GitHub's version"

      class_option :repository, type: :string,
                                default: "https://github.com/decidim/decidim.git",
                                desc: "Use a specific GIT repository (valid in conjunction with --edge or --branch)"

      class_option :recreate_db, type: :boolean,
                                 default: false,
                                 desc: "Recreate test database"

      class_option :seed_db, type: :boolean,
                             default: false,
                             desc: "Seed test database"

      class_option :skip_bundle, type: :boolean,
                                 default: true, # this is to avoid installing gems in this step yet (done by InstallGenerator)
                                 desc: "Don't run bundle install"

      class_option :skip_gemfile, type: :boolean,
                                  default: false,
                                  desc: "Don't generate a Gemfile for the application"

      class_option :demo, type: :boolean,
                          default: false,
                          desc: "Generate demo authorization handlers"

      class_option :profiling, type: :boolean,
                               default: false,
                               desc: "Add the necessary gems to profile the app"

      class_option :force_ssl, type: :string,
                               default: "true",
                               desc: "Doesn't force to use ssl"

      class_option :locales, type: :string,
                             default: "",
                             desc: "Force the available locales to the ones specified. Separate with comas"

      class_option :storage, type: :string,
                             default: "local",
                             desc: "Setup the Gemfile with the appropiate gem to handle a storage provider. Supported options are: local (default), s3, gcs, azure"

      class_option :queue, type: :string,
                           default: "",
                           desc: "Setup the Gemfile with the appropiate gem to handle a queue adapter provider. Supported options are: (empty, does nothing) and sidekiq"

      class_option :skip_webpack_install, type: :boolean,
                                          default: true,
                                          desc: "Don't run Webpack install"

      def database_yml
        template "database.yml.erb", "config/database.yml", force: true
      end

      def decidim_controller
        template "decidim_controller.rb.erb", "app/controllers/decidim_controller.rb", force: true
      end

      def docker
        template "Dockerfile.erb", "Dockerfile"
        template "docker-compose.yml.erb", "docker-compose.yml"
      end

      def etherpad
        template "docker-compose-etherpad.yml", "docker-compose-etherpad.yml"
      end

      def cable_yml
        template "cable.yml.erb", "config/cable.yml", force: true
      end

      def readme
        template "README.md.erb", "README.md", force: true
      end

      def license
        template "LICENSE-AGPLv3.txt", "LICENSE-AGPLv3.txt"
      end

      def gemfile
        return if options[:skip_gemfile]

        if branch.present?
          get target_gemfile, "Gemfile", force: true
          append_file "Gemfile", %(\ngem "net-imap", "~> 0.2.3", group: :development)
          append_file "Gemfile", %(\ngem "net-pop", "~> 0.1.1", group: :development)
          append_file "Gemfile", %(\ngem "net-smtp", "~> 0.3.1", group: :development)
          get "#{target_gemfile}.lock", "Gemfile.lock", force: true
        else
          copy_file target_gemfile, "Gemfile", force: true
          copy_file "#{target_gemfile}.lock", "Gemfile.lock", force: true
        end

        gsub_file "Gemfile", /gem "#{current_gem}".*/, "gem \"#{current_gem}\", #{gem_modifier}"

        return unless current_gem == "decidim"

        gsub_file "Gemfile", /gem "decidim-dev".*/, "gem \"decidim-dev\", #{gem_modifier}"

        %w(conferences consultations elections initiatives templates).each do |component|
          if options[:demo]
            gsub_file "Gemfile", /gem "decidim-#{component}".*/, "gem \"decidim-#{component}\", #{gem_modifier}"
          else
            gsub_file "Gemfile", /gem "decidim-#{component}".*/, "# gem \"decidim-#{component}\", #{gem_modifier}"
          end
        end
      end

      def add_storage_provider
        template "storage.yml.erb", "config/storage.yml", force: true

        providers = options[:storage].split(",")

        abort("#{providers} is not supported as storage provider, please use local, s3, gcs or azure") unless (providers - %w(local s3 gcs azure)).empty?
        gsub_file "config/environments/production.rb",
                  /config.active_storage.service = :local/,
                  "config.active_storage.service = Rails.application.secrets.dig(:storage, :provider) || :local"

        add_production_gems do
          gem "aws-sdk-s3", require: false if providers.include?("s3")
          gem "azure-storage-blob", require: false if providers.include?("azure")
          gem "google-cloud-storage", "~> 1.11", require: false if providers.include?("gcs")
        end
      end

      def add_queue_adapter
        adapter = options[:queue]

        abort("#{adapter} is not supported as a queue adapter, please use sidekiq for the moment") unless adapter.in?(["", "sidekiq"])

        return unless adapter == "sidekiq"

        template "sidekiq.yml.erb", "config/sidekiq.yml", force: true

        gsub_file "config/environments/production.rb",
                  /# config.active_job.queue_adapter     = :resque/,
                  "config.active_job.queue_adapter = ENV['QUEUE_ADAPTER'] if ENV['QUEUE_ADAPTER'].present?"

        prepend_file "config/routes.rb", "require \"sidekiq/web\"\n\n"
        route <<~RUBY
          authenticate :user, ->(u) { u.admin? } do
            mount Sidekiq::Web => "/sidekiq"
          end
        RUBY

        add_production_gems do
          gem "sidekiq"
        end
      end

      def add_production_gems(&block)
        return if options[:skip_gemfile]

        if block
          @production_gems ||= []
          @production_gems << block
        elsif @production_gems.present?
          gem_group :production do
            @production_gems.map(&:call)
          end
        end
      end

      def tweak_bootsnap
        gsub_file "config/boot.rb", %r{require 'bootsnap/setup'.*$}, <<~RUBY.rstrip
          require "bootsnap"

          env = ENV["RAILS_ENV"] || "development"

          Bootsnap.setup(
            cache_dir: File.expand_path(File.join("..", "tmp", "cache"), __dir__),
            development_mode: env == "development",
            load_path_cache: true,
            compile_cache_iseq: !ENV["SIMPLECOV"],
            compile_cache_yaml: true
          )
        RUBY
      end

      def tweak_spring
        return unless File.exist?("config/spring.rb")

        prepend_to_file "config/spring.rb", "require \"decidim/spring\"\n\n"
      end

      def add_ignore_uploads
        append_file ".gitignore", "\n# Ignore public uploads\npublic/uploads" unless options["skip_git"]
      end

      def remove_default_error_pages
        remove_file "public/404.html"
        remove_file "public/500.html"
      end

      def decidim_initializer
        copy_file "initializer.rb", "config/initializers/decidim.rb"

        gsub_file "config/environments/production.rb",
                  /config.log_level = :info/,
                  "config.log_level = %w(debug info warn error fatal).include?(ENV['RAILS_LOG_LEVEL']) ? ENV['RAILS_LOG_LEVEL'] : :info"

        gsub_file "config/environments/production.rb",
                  %r{# config.asset_host = 'http://assets.example.com'},
                  "config.asset_host = ENV['RAILS_ASSET_HOST'] if ENV['RAILS_ASSET_HOST'].present?"

        if options[:force_ssl] == "false"
          gsub_file "config/initializers/decidim.rb",
                    /# config.force_ssl = true/,
                    "config.force_ssl = false"
        end
        return if options[:locales].blank?

        gsub_file "config/initializers/decidim.rb",
                  /#{Regexp.escape("# config.available_locales = %w(en ca es)")}/,
                  "config.available_locales = %w(#{options[:locales].gsub(",", " ")})"
        gsub_file "config/initializers/decidim.rb",
                  /#{Regexp.escape("config.available_locales = Rails.application.secrets.decidim[:available_locales].presence || [:en]")}/,
                  "# config.available_locales = Rails.application.secrets.decidim[:available_locales].presence || [:en]"
      end

      def authorization_handler
        return unless options[:demo]

        copy_file "dummy_authorization_handler.rb", "app/services/dummy_authorization_handler.rb"
        copy_file "another_dummy_authorization_handler.rb", "app/services/another_dummy_authorization_handler.rb"
        copy_file "verifications_initializer.rb", "config/initializers/decidim_verifications.rb"
      end

      def sms_gateway
        return unless options[:demo]

        gsub_file "config/initializers/decidim.rb",
                  /# config.sms_gateway_service = "MySMSGatewayService"/,
                  "config.sms_gateway_service = 'Decidim::Verifications::Sms::ExampleGateway'"
      end

      def budgets_workflows
        return unless options[:demo]

        copy_file "budgets_workflow_random.rb", "lib/budgets_workflow_random.rb"
        copy_file "budgets_workflow_random.en.yml", "config/locales/budgets_workflow_random.en.yml"

        copy_file "budgets_initializer.rb", "config/initializers/decidim_budgets.rb"
      end

      def timestamp_service
        return unless options[:demo]

        gsub_file "config/initializers/decidim.rb",
                  /# config.timestamp_service = "MyTimestampService"/,
                  "config.timestamp_service = \"Decidim::Initiatives::DummyTimestamp\""
      end

      def pdf_signature_service
        return unless options[:demo]

        gsub_file "config/initializers/decidim.rb",
                  /# config.pdf_signature_service = "MyPDFSignatureService"/,
                  "config.pdf_signature_service = \"Decidim::Initiatives::PdfSignatureExample\""
      end

      def machine_translation_service
        return unless options[:demo]

        gsub_file "config/initializers/decidim.rb",
                  /# config.machine_translation_service = "MyTranslationService"/,
                  "config.machine_translation_service = 'Decidim::Dev::DummyTranslator'"
      end

      def install
        Decidim::Generators::InstallGenerator.start(
          [
            "--recreate_db=#{options[:recreate_db]}",
            "--seed_db=#{options[:seed_db]}",
            "--skip_gemfile=#{options[:skip_gemfile]}",
            "--app_name=#{app_name}",
            "--profiling=#{options[:profiling]}"
          ]
        )
      end

      private

      def gem_modifier
        @gem_modifier ||= if options[:path]
                            %(path: "#{options[:path]}")
                          elsif branch.present?
                            %(git: "#{repository}", branch: "#{branch}")
                          else
                            %("#{Decidim::Generators.version}")
                          end
      end

      def branch
        return if options[:path]

        @branch ||= options[:edge] ? Decidim::Generators.edge_git_branch : options[:branch].presence
      end

      def repository
        @repository ||= options[:repository] || "https://github.com/decidim/decidim.git"
      end

      def app_name
        options[:app_name] || super
      end

      def app_const_base
        app_name.gsub(/\W/, "_").squeeze("_").camelize
      end

      def current_gem
        return "decidim" unless options[:path]

        @current_gem ||= File.read(gemspec).match(/name\s*=\s*['"](?<name>.*)["']/)[:name]
      end

      def gemspec
        File.expand_path(Dir.glob("*.gemspec", base: expanded_path).first, expanded_path)
      end

      def target_gemfile
        root = if options[:path]
                 expanded_path
               elsif branch.present?
                 "https://raw.githubusercontent.com/decidim/decidim/#{branch}/decidim-generators"
               else
                 root_path
               end

        File.join(root, "Gemfile")
      end

      def expanded_path
        File.expand_path(options[:path])
      end

      def root_path
        File.expand_path(File.join("..", "..", ".."), __dir__)
      end
    end
  end
end
