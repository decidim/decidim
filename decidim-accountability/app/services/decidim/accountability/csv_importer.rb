# frozen_string_literal: true
require "csv"

module Decidim
  module Accountability
    # This class handles importing results from a CSV file.
    # Needs a `current_feature` param with a `Decidim::Feature`
    # in order to import the results in that feature.
    class CSVImporter
      include Decidim::FormFactory

      # Public: Initializes the service.
      # feature       - A Decidim::Feature to import the results into.
      # csv_file_path - The path to the csv file.
      def initialize(feature, csv_file_path)
        @feature = feature
        @csv_file_path = csv_file_path
        @extra_context = { current_feature: feature, current_organization: feature.organization}
      end

      def import!
        errors = []

        ActiveRecord::Base.transaction do
          i = 1
          CSV.foreach(@csv_file_path, headers: true) do |row|
            i += 1
            next if row.empty?

            params = {}
            params["result"] = row.to_hash

            if row["result_id"].present?
              existing_result = Decidim::Accountability::Result.find_by(id: row['result_id'].to_i)
              unless existing_result.present?
                errors << [i, [I18n.t("imports.create.not_found", scope: "decidim.accountability.admin", result_id: row["result_id"])]]
                next
              end
            elsif row["external_id"].present?
              existing_result = Decidim::Accountability::Result.find_by(external_id: row["external_id"])
              params["result"]["id"] = existing_result.id if existing_result
            end

            if row["parent_id"].blank? && row["parent_external_id"].present?
              if parent = Decidim::Accountability::Result.find_by(external_id: row["parent_external_id"])
                params["result"]["parent_id"] = parent.id
              end
            end

            if row["decidim_accountability_status_id"].present? && status = Decidim::Accountability::Status.find_by(id: row["decidim_accountability_status_id"])
              params["result"]["progress"] = status.progress if status.progress.present?
            end

            default_locale = @feature.participatory_space.organization.default_locale
            available_locales = @feature.participatory_space.organization.available_locales

            available_locales.each do |locale|
              params["result"]["title_#{locale}"] = params["result"]["title_#{default_locale}"] if params["result"]["title_#{locale}"].blank?
              params["result"]["description_#{locale}"] = params["result"]["description_#{default_locale}"] if params["result"]["description_#{locale}"].blank?
            end

            if params["result"]["proposal_ids"].presence
              proposal_ids = params["result"]["proposal_ids"].split(";")
              params["result"]["proposal_ids"] = proposal_ids
            end

            @form = form(Decidim::Accountability::Admin::ResultForm).from_params(params, @extra_context)

            begin
              start_date = Date.parse(row["start_date"]) if row["start_date"].present?
            rescue ArgumentError
              @form.errors.add(:start_date, :invalid_date)
            end

            begin
              end_date = Date.parse(row["end_date"]) if row["end_date"].present?
            rescue ArgumentError
              @form.errors.add(:end_date, :invalid_date)
            end

            # add form errors now because when calling valid on the form in UpdateResult/CreateResult will clear the errors
            errors << [i, @form.errors.full_messages] if @form.errors.any?

            if existing_result #update existing result
              Decidim::Accountability::Admin::UpdateResult.call(@form, existing_result) do
                on(:invalid) do
                  errors << [i, @form.errors.full_messages]
                end
              end
            else #create new result
              Decidim::Accountability::Admin::CreateResult.call(@form) do
                on(:invalid) do
                  errors << [i, @form.errors.full_messages]
                end
              end
            end
          end

          raise ActiveRecord::Rollback if errors.any?
        end

        errors
      end
    end
  end
end
