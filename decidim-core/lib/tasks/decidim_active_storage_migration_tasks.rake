# frozen_string_literal: true

namespace :decidim do
  namespace :active_storage_migrations do
    desc "Migrates attachments from Carrierwave to ActiveStorage"
    task migrate_from_carrierwave_to_active_storage: :environment do
      # Setup a new logger, using the timestamp to identify each migration
      logger = ActiveSupport::TaggedLogging.new(Logger.new("log/#{Time.current.strftime("%Y%m%d%H%M")}_activestorage_migration.log"))
      routes_mappings = []

      Decidim::CarrierWaveMigratorService::MIGRATION_ATTRIBUTES.each do |(klass, cw_attribute, cw_uploader, as_attribute)|
        Decidim::CarrierWaveMigratorService.migrate_attachment!({
                                                                  klass:, cw_attribute:,
                                                                  cw_uploader:, as_attribute:,
                                                                  logger:,
                                                                  routes_mappings:
                                                                })
      end
      Decidim::CarrierWaveMigratorService.migrate_content_blocks_attachments!(logger:, routes_mappings:)

      path = Rails.root.join("tmp/attachment_mappings.csv")
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.binwrite(path, Decidim::Exporters::CSV.new(routes_mappings).export.read)
    end

    desc "Checks attachments migrated from Carrierwave to ActiveStorage"
    task check_migration_from_carrierwave_to_active_storage: :environment do
      # Setup a new logger, using the timestamp to identify each migration
      logger = ActiveSupport::TaggedLogging.new(Logger.new("log/#{Time.current.strftime("%Y%m%d%H%M")}_activestorage_migration_check.log"))
      Decidim::CarrierWaveMigratorService::MIGRATION_ATTRIBUTES.each do |(klass, cw_attribute, cw_uploader, as_attribute)|
        Decidim::CarrierWaveMigratorService.check_migration({
                                                              klass:, cw_attribute:,
                                                              cw_uploader:, as_attribute:,
                                                              logger:
                                                            })
      end
      Decidim::CarrierWaveMigratorService.check_content_blocks_attachments(logger:)
    end

    desc "Migrates inline images to ActiveStorage editor_image attachments"
    task :migrate_inline_images_to_active_storage, [:admin_email] => :environment do |_t, args|
      user = Decidim::User.find_by(email: args[:admin_email])

      raise "Invalid admin. Please, provide the email of an admin with permissions to create editor images" unless user&.admin? && user&.admin_terms_accepted?

      inline_images_available_attributes.each do |model, attributes|
        puts "=== Updating model #{model.name} (attributes: #{attributes.join(", ")})..."
        model.all.each do |item|
          attributes.each do |attribute|
            item.update(attribute => rewrite_value(item.send(attribute), user))
          end
        end
        puts "=== Finished update of model #{model.name}\n\n"
      end
    end

    def rewrite_value(value, user)
      if value.is_a?(Hash)
        value.transform_values do |nested_value|
          rewrite_value(nested_value, user)
        end
      else
        parser = Decidim::ContentParsers::InlineImagesParser.new(value, user:)
        parser.rewrite
      end
    end

    def inline_images_available_attributes
      {
        "Decidim::Accountability::Result" => %w(description),
        "Decidim::Proposals::Proposal" => %w(body answer cost_report execution_period),
        "Decidim::Votings::Voting" => %w(description),
        "Decidim::Elections::Question" => %w(description),
        "Decidim::Elections::Answer" => %w(description),
        "Decidim::Elections::Election" => %w(description),
        "Decidim::Initiative" => %w(description answer),
        "Decidim::InitiativesType" => %w(description extra_fields_legal_information),
        "Decidim::Assembly" => %w(short_description description purpose_of_action composition internal_organisation announcement closing_date_reason special_features),
        "Decidim::Forms::Questionnaire" => %w(description tos),
        "Decidim::Forms::Question" => %w(description),
        "Decidim::Organization" => %w(welcome_notification_body admin_terms_of_use_body description highlighted_content_banner_short_description id_documents_explanation_text),
        "Decidim::StaticPage" => %w(content),
        "Decidim::ContextualHelpSection" => %w(content),
        "Decidim::Category" => %w(description),
        "Decidim::Blogs::Post" => %w(body),
        "Decidim::Pages::Page" => %w(body),
        "Decidim::Sortitions::Sortition" => %w(additional_info witnesses cancel_reason),
        "Decidim::Consultations::Question" => %w(title question_context what_is_decided instructions),
        "Decidim::Consultation" => %w(description),
        "Decidim::Debates::Debate" => %w(description instructions information_updates conclusions),
        "Decidim::Budgets::Budget" => %w(description),
        "Decidim::Budgets::Project" => %w(description),
        "Decidim::ConferenceSpeaker" => %w(short_bio),
        "Decidim::Conferences::RegistrationType" => %w(description),
        "Decidim::Conference" => %w(short_description description objectives registration_terms),
        "Decidim::ParticipatoryProcessGroup" => %w(description),
        "Decidim::ParticipatoryProcess" => %w(short_description description announcement),
        "Decidim::ParticipatoryProcessStep" => %w(description),
        "Decidim::Meetings::AgendaItem" => %w(description),
        "Decidim::Meetings::Meeting" => %w(registration_terms description registration_email_custom_content closing_report)
      }.each_with_object({}) do |(main_model, attributes), hash|
        hash[main_model.constantize] = attributes
      rescue NameError
        hash
      end
    end
  end
end
