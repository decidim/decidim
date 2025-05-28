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
                                default: "https://github.com/tremend-cofe/decidim.git",
                                desc: "Use a specific GIT repository (valid in conjunction with --edge or --branch)"

      class_option :recreate_db, type: :boolean,
                                 default: false,
                                 desc: "Recreate test database"

      class_option :seed_db, type: :boolean,
                             default: false,
                             desc: "Seed test database"

      class_option :skip_bundle, type: :boolean,
                                 default: true, # this is to avoid installing gems in this step yet (done by InstallGenerator)
                                 desc: "Do not run bundle install"

      class_option :skip_gemfile, type: :boolean,
                                  default: false,
                                  desc: "Do not generate a Gemfile for the application"

      class_option :demo, type: :boolean,
                          default: false,
                          desc: "Generate demo authorization handlers"

      class_option :profiling, type: :boolean,
                               default: false,
                               desc: "Add the necessary gems to profile the app"

      class_option :force_ssl, type: :string,
                               default: "true",
                               desc: "Does not force to use ssl"

      class_option :locales, type: :string,
                             default: "",
                             desc: "Force the available locales to the ones specified. Separate with comas"

      class_option :storage, type: :string,
                             default: "local",
                             desc: "Setup the Gemfile with the appropriate gem to handle a storage provider. Supported options are: local (default), s3, gcs, azure"

      class_option :queue, type: :string,
                           default: "",
                           desc: "Setup the Gemfile with the appropriate gem to handle a queue adapter provider. Supported options are: (empty, does nothing) and sidekiq"

      class_option :skip_webpack_install, type: :boolean,
                                          default: true,
                                          desc: "Do not run Webpack install"

      class_option :dev_ssl, type: :boolean,
                             default: false,
                             desc: "Do not add Puma development SSL configuration options"

      # we disable the webpacker installation as we will use shakapacker
      def webpacker_gemfile_entry
        []
      end

      def remove_old_assets
        remove_file "config/initializers/assets.rb"
        remove_dir("app/assets")
        remove_dir("app/javascript")
      end

      def remove_sprockets_requirement
        gsub_file "config/application.rb", %r{require ['"]rails/all['"]\R}, <<~RUBY
          require "decidim/rails"

          # Add the frameworks used by your app that are not loaded by Decidim.
          # require "action_mailbox/engine"
          # require "action_text/engine"
          require "action_cable/engine"
          require "rails/test_unit/railtie"
        RUBY

        gsub_file "config/environments/development.rb", /config\.assets.*$/, ""
        gsub_file "config/environments/test.rb", /config\.assets.*$/, ""
        gsub_file "config/environments/production.rb", /config\.assets.*$/, ""
      end

      def database_yml
        template "database.yml.erb", "config/database.yml", force: true
      end

      def decidim_controller
        template "decidim_controller.rb.erb", "app/controllers/decidim_controller.rb", force: true
      end

      def docker
        template "Dockerfile.erb", "Dockerfile", force: true
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

      def rubocop
        copy_file ".rubocop.yml", ".rubocop.yml"
      end

      def ruby_version
        copy_file ".ruby-version", ".ruby-version", force: true
      end

      def node_version
        copy_file ".node-version", ".node-version"
      end

      def gemfile
        return if options[:skip_gemfile]

        if branch.present?
          get target_gemfile, "Gemfile", force: true
          append_file "Gemfile", %(\ngem "net-imap", "~> 0.5.0", group: :development)
          append_file "Gemfile", %(\ngem "net-pop", "~> 0.1.1", group: :development)
          append_file "Gemfile", %(\ngem "net-smtp", "~> 0.5.0", group: :development)
          get "#{target_gemfile}.lock", "Gemfile.lock", force: true
        else
          copy_file target_gemfile, "Gemfile", force: true
          copy_file "#{target_gemfile}.lock", "Gemfile.lock", force: true
        end

        gsub_file "Gemfile", /gem "#{current_gem}".*/, "gem \"#{current_gem}\", #{gem_modifier}"

        return unless current_gem == "decidim"

        gsub_file "Gemfile", /gem "decidim-dev".*/, "gem \"decidim-dev\", #{gem_modifier}"

        %w(ai conferences design initiatives templates collaborative_texts elections).each do |component|
          if options[:demo]
            gsub_file "Gemfile", /gem "decidim-#{component}".*/, "gem \"decidim-#{component}\", #{gem_modifier}"
          else
            gsub_file "Gemfile", /gem "decidim-#{component}".*/, "# gem \"decidim-#{component}\", #{gem_modifier}"
          end
        end
      end

      def add_storage_provider
        copy_file "storage.yml", "config/storage.yml", force: true

        providers = options[:storage].split(",")

        abort("#{providers} is not supported as storage provider, please use local, s3, gcs or azure") unless (providers - %w(local s3 gcs azure)).empty?
        gsub_file "config/environments/production.rb",
                  /config.active_storage.service = :local/,
                  %{config.active_storage.service = Decidim::Env.new("STORAGE_PROVIDER", "local").to_s}

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

        gsub_file "config/environments/development.rb",
                  /Rails.application.configure do/,
                  "Rails.application.configure do\n  config.active_job.queue_adapter = :sidekiq\n"
        gsub_file "config/environments/production.rb",
                  /# config.active_job.queue_adapter     = :resque/,
                  "config.active_job.queue_adapter = ENV['QUEUE_ADAPTER'] if ENV['QUEUE_ADAPTER'].present?"

        prepend_file "config/routes.rb", "require \"sidekiq/web\"\n\n"

        route <<~RUBY
          authenticate :user, ->(u) { u.admin? } do
            mount Sidekiq::Web => "/sidekiq"
          end
        RUBY

        append_file "Gemfile", %(gem "sidekiq")
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

      def tweak_csp_initializer
        return unless File.exist?("config/initializers/content_security_policy.rb")

        remove_file("config/initializers/content_security_policy.rb")
        create_file "config/initializers/content_security_policy.rb" do
          %(# For tuning the Content Security Policy, check the Decidim documentation site
# https://docs.decidim.org/develop/en/customize/content_security_policy)
        end
      end

      def puma_ssl_options
        return unless options[:dev_ssl]

        append_file "config/puma.rb", <<~CONFIG

          # Development SSL
          if ENV["DEV_SSL"] && defined?(Bundler) && (dev_gem = Bundler.load.specs.find { |spec| spec.name == "decidim-dev" })
            cert_dir = ENV.fetch("DEV_SSL_DIR") { "\#{dev_gem.full_gem_path}/lib/decidim/dev/assets" }
            ssl_bind(
              "0.0.0.0",
              ENV.fetch("DEV_SSL_PORT") { 3443 },
              cert_pem: File.read("\#{cert_dir}/ssl-cert.pem"),
              key_pem: File.read("\#{cert_dir}/ssl-key.pem")
            )
          end
        CONFIG
      end

      def modify_gitignore
        return if options[:skip_git]

        append_file ".gitignore", <<~GITIGNORE

          # Ignore env configuration files
          .env
          .envrc
          .rbenv-vars

          # Ignore the files and folders generated through Webpack
          /public/decidim-packs
          /public/packs-test
          /public/sw.js
          /public/sw.js.map

          # Ignore node modules
          /node_modules
        GITIGNORE
      end

      def add_ignore_tailwind_configuration
        append_file ".gitignore", "\n\n# Ignore Tailwind configuration\ntailwind.config.js" unless options["skip_git"]
      end

      def remove_default_error_pages
        remove_file "public/404.html"
        remove_file "public/500.html"
      end

      def remove_default_favicon
        remove_file "public/favicon.ico"
      end

      def decidim_initializer
        copy_file "initializer.rb", "config/initializers/decidim.rb"

        gsub_file "config/environments/production.rb",
                  /config.log_level = :info/,
                  "config.log_level = %w(debug info warn error fatal).include?(ENV['RAILS_LOG_LEVEL']) ? ENV['RAILS_LOG_LEVEL'] : :info"

        gsub_file "config/environments/production.rb",
                  %r{# config.asset_host = "http://assets.example.com"},
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
                  /#{Regexp.escape("config.available_locales = Decidim::Env.new(\"DECIDIM_AVAILABLE_LOCALES\", \"ca,cs,de,en,es,eu,fi,fr,it,ja,nl,pl,pt,ro\").to_array.to_json")}/,
                  "# config.available_locales = Decidim::Env.new(\"DECIDIM_AVAILABLE_LOCALES\", \"ca,cs,de,en,es,eu,fi,fr,it,ja,nl,pl,pt,ro\").to_array.to_json"
      end

      def dev_performance_config
        gsub_file "config/environments/development.rb", /^end\n$/, <<~CONFIG

            # Performance configs for local testing
            if ENV.fetch("RAILS_BOOST_PERFORMANCE", false).to_s == "true"
              # Indicate boost performance mode
              config.boost_performance = true
              # Enable caching and eager load
              config.eager_load = true
              config.cache_classes = true
              # Logging
              config.log_level = :info
              config.action_view.logger = nil
              # Compress the HTML responses with gzip
              config.middleware.use Rack::Deflater
            end
          end
        CONFIG
      end

      def authorization_handler
        return unless options[:demo]

        copy_file "dummy_authorization_handler.rb", "app/services/dummy_authorization_handler.rb"
        copy_file "ephemeral_dummy_authorization_handler.rb", "app/services/ephemeral_dummy_authorization_handler.rb"
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

      def initiative_signatures_workflows
        return unless options[:demo]

        copy_file "dummy_signature_handler.rb", "app/services/dummy_signature_handler.rb"
        copy_file "dummy_signature_handler_form.html.erb", "app/views/decidim/initiatives/initiative_signatures/dummy_signature/_form.html.erb"
        copy_file "dummy_signature_handler_form.html.erb", "app/views/decidim/initiatives/initiative_signatures/ephemeral_dummy_signature/_form.html.erb"
        copy_file "dummy_signature_handler_form.html.erb", "app/views/decidim/initiatives/initiative_signatures/dummy_signature_with_personal_data/_form.html.erb"
        copy_file "dummy_sms_mobile_phone_validator.rb", "app/services/dummy_sms_mobile_phone_validator.rb"
        copy_file "initiatives_initializer.rb", "config/initializers/decidim_initiatives.rb"
      end

      def ai_toolkit
        return unless options[:demo]

        copy_file "ai_initializer.rb", "config/initializers/decidim_ai.rb"
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
                  "config.pdf_signature_service = \"Decidim::PdfSignatureExample\""
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
        @repository ||= options[:repository] || "https://github.com/tremend-cofe/decidim.git"
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
                 "https://raw.githubusercontent.com/tremend-cofe/decidim/#{branch}/decidim-generators"
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
