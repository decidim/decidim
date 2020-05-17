# frozen_string_literal: true

require "csv"

module Decidim
  module Accountability
    # This class handles importing results from a CSV file.
    # Needs a `current_component` param with a `Decidim::component`
    # in order to import the results in that component.
    class ResultsCSVImporter
      include Decidim::FormFactory

      # Public: Initializes the service.
      # component     - A Decidim::component to import the results into.
      # csv_file      - The contents of the CSV to read.
      def initialize(component, csv_file, current_user)
        @component = component
        @csv_file = csv_file

        @extra_context = {
          current_component: component,
          current_organization: component.organization,
          current_user: current_user,
          current_participatory_space: component.participatory_space
        }
      end

      def import!
        errors = []

        ActiveRecord::Base.transaction do
          i = 1
          csv = CSV.new(@csv_file, headers: true, col_sep: ";")
          while (row = csv.shift).present?
            i += 1
            next if row.empty?

            params = set_params_for_import_result_form(row, @component)
            existing_result = Decidim::Accountability::Result.find_by(id: row["id"]) if row["id"].present?
            @form = form(Decidim::Accountability::Admin::ResultForm).from_params(params, @extra_context)
            params["result"].merge!(parse_date_params(row, "start_date"))
            params["result"].merge!(parse_date_params(row, "end_date"))
            errors << [i, @form.errors.full_messages] if @form.errors.any?

            if existing_result.present?
              Decidim::Accountability::Admin::UpdateImportedResult.call(@form, existing_result, params["result"]["parent/id"]) do
                on(:invalid) do
                  errors << [i, @form.errors.full_messages]
                end
              end
            else
              Decidim::Accountability::Admin::CreateImportedResult.call(@form, params["result"]["parent/id"]) do
                on(:invalid) do
                  errors << [i, @form.errors.full_messages]
                end
              end
            end
          end

          raise ActiveRecord::Rollback if errors.any?

          Rails.logger.info "Processed: #{i}"
        end
        remove_invalid_results

        errors
      end

      private

      def set_params_for_import_result_form(row, component)
        params = {}
        params["result"] = row.to_hash
        default_locale = component.participatory_space.organization.default_locale
        available_locales = component.participatory_space.organization.available_locales
        params["result"].merge!(get_locale_attributes(default_locale, available_locales, :title, row))
        params["result"].merge!(get_locale_attributes(default_locale, available_locales, :description, row))
        params["result"].merge!(get_proposal_ids(row["proposal_urls"]))
        params
      end

      def get_locale_attributes(default_locale, available_locales, field, row)
        array_field_localized = available_locales.map do |locale|
          if row["#{field}/#{locale}"].present?
            ["#{field}_#{locale}", row["#{field}/#{locale}"]]
          else
            ["#{field}_#{locale}", row["#{field}/#{default_locale}"]]
          end
        end

        Hash[*array_field_localized.flatten]
      end

      def parse_date_params(row, field)
        begin
          return { field => Date.parse(row[field]) } if row[field].present?
        rescue ArgumentError
          @form.errors.add(field.to_sym, :invalid_date)
        end
        {}
      end

      def get_proposal_ids(proposal_urls)
        if proposal_urls.present?
          proposal_urls = proposal_urls.split(";")
          { "proposal_ids" => proposal_urls.map { |proposal_url| proposal_url.scan(/\d$/).first.to_i } }
        else
          {}
        end
      end

      def remove_invalid_results
        Decidim::Accountability::Result.includes(:parent).references(:parent)
                                       .where(parents_decidim_accountability_results: { id: nil })
                                       .where.not(parent_id: nil).each do |result|
          DestroyResult.call(result, @extra_context[:current_user])
        end
      end
    end
  end
end
