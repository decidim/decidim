# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Registers records for the WYSIWYG content migration"
    task :register_wysiwyg_migration do
      # Core
      Decidim::Upgrade::WysiwygMigrator.register_model(
        "Decidim::Organization",
        [:description, :omnipresent_banner_short_description, :highlighted_content_banner_short_description, :welcome_notification_body, :admin_terms_of_service_body]
      )
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Category", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::ContextualHelpSection", [:content])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::StaticPage", [:content])

      # Participatory spaces
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Assembly", [:short_description, :description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Conference", [:short_description, :description, :registration_terms])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Conferences::RegistrationType", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Initiative", [:description, :answer])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::InitiativesType", [:description, :extra_fields_legal_information])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Votings::Voting", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::ParticipatoryProcess", [:short_description, :description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::ParticipatoryProcessStep", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::ParticipatoryProcessGroup", [:description])

      # Components
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Accountability::Result", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Accountability::Status", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Accountability::MilestoneEntry", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Blogs::Post", [:body])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Budgets::Budget", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Budgets::Project", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Debates::Debate", [:description, :instructions, :information_updates, :conclusions])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Elections::Election", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Elections::Answer", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Forms::Questionnaire", [:description, :tos])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Forms::Question", [:description])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Meetings::Meeting", [:description, :registration_terms, :registration_email_custom_content, :closing_report])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Pages::Page", [:body])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Proposals::Proposal", [:body, :answer, :cost_report, :execution_period])
      Decidim::Upgrade::WysiwygMigrator.register_model("Decidim::Sortitions::Sortition", [:witnesses, :additional_info, :cancel_reason])
    end

    desc "Updates the content entered through the WYSIWYG editors"
    task migrate_wysiwyg_content: [:environment, :register_wysiwyg_migration] do
      log_info "Updating WYSIWYG content for Decidim records..."

      log_info "Updating models..."
      current_model = nil
      Decidim::Upgrade::WysiwygMigrator.update_models do |model_class, range|
        if model_class != current_model
          current_model = model_class
          log_info "-- Updating #{current_model.model_name.human(count: 2)} (#{current_model})..."
        end
        log_info "    #{range}"
      end

      log_info "Updating component settings..."
      current_manifest = nil
      Decidim::Upgrade::WysiwygMigrator.update_component_settings do |manifest_name, range|
        if manifest_name != current_manifest
          current_manifest = manifest_name
          log_info "-- Updating #{current_manifest}..."
        end
        log_info "    #{range}"
      end

      log_info "Updating content blocks..."
      log_info "-- Updating static_page:summary"
      Decidim::Upgrade::WysiwygMigrator.update_settings(
        Decidim::ContentBlock.where(scope_name: "static_page", manifest_name: "summary"),
        ["summary"]
      ) do |_klass, range|
        log_info "    #{range}"
      end

      log_info ""
      log_info "Done!"
    end

    private

    def log_info(msg)
      puts msg
      Rails.logger.info(msg)
    end
  end
end
