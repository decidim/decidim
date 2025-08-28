# frozen_string_literal: true

module Decidim
  # This query finds the public ActionLog entries that can be shown in the
  # activities views of the application within a Decidim Organization. It is
  # intended to be used in the "Last activities" content block in the homepage,
  # and also in the "Last activities" page, to retrieve public activity of this
  # organization.
  class LastActivity < Decidim::Query
    def initialize(organization, options = {})
      @organization = organization
      @current_user = options[:current_user]
    end

    def query
      @query ||= begin
        query = base_query
        query = filter_moderated(query)
        query = filter_spaces(query)
        query = filter_deleted(query)
        query = filter_withdrawn(query)
        query.with_new_resource_type("all")
      end
    end

    private

    attr_reader :organization, :current_user

    def base_query
      ActionLog
        .where(organization:, visibility:)
        .order(created_at: :desc)
    end

    def visibility
      %w(public-only all)
    end

    def filter_moderated(query)
      # Filter out the items that have been moderated.
      query.joins(
        <<~SQL.squish
          LEFT JOIN decidim_moderations
            ON decidim_moderations.decidim_reportable_type = decidim_action_logs.resource_type
            AND decidim_moderations.decidim_reportable_id = decidim_action_logs.resource_id
            AND decidim_moderations.hidden_at IS NOT NULL
      SQL
      ).where(decidim_moderations: { id: nil })
    end

    def filter_withdrawn(query)
      # Filter out the items that have been withdrawn.
      conditions = []

      ActionLog.public_resource_types.each do |resource_type|
        klass = resource_type.constantize

        condition = if klass.respond_to?(:not_withdrawn)
                      Arel.sql(
                        [
                          "decidim_action_logs.resource_type = '#{resource_type}'",
                          "decidim_action_logs.resource_id IN (#{Arel.sql(klass.not_withdrawn.select(:id).to_sql)})"
                        ].join(" AND ")
                      ).to_s
                    else
                      Arel.sql("decidim_action_logs.resource_type = '#{resource_type}'").to_s
                    end

        conditions << "(#{condition})"
      end

      query.where(Arel.sql(conditions.join(" OR ")).to_s)
    end

    def filter_spaces(query)
      conditions = []

      Decidim.participatory_space_manifests.map do |manifest|
        klass = manifest.model_class_name.constantize

        condition = if klass.include?(Decidim::HasPrivateUsers)
                      Arel.sql(
                        <<~SQL.squish
                          (
                            decidim_action_logs.participatory_space_type = '#{manifest.model_class_name}' AND#{" "}
                            decidim_action_logs.participatory_space_id IN (#{Arel.sql(klass.visible_for(current_user).select(:id).to_sql)})
                          ) OR#{" "}
                          (
                            decidim_action_logs.resource_type = '#{manifest.model_class_name}' AND#{" "}
                            decidim_action_logs.resource_id IN (#{Arel.sql(klass.visible_for(current_user).select(:id).to_sql)})
                          )
                        SQL
                      ).to_s
                    else
                      Arel.sql(
                        [
                          "decidim_action_logs.resource_type = '#{manifest.model_class_name}'",
                          "decidim_action_logs.participatory_space_type = '#{manifest.model_class_name}'"
                        ].join(" OR ")
                      ).to_s
                    end

        conditions << "(#{condition})"
      end
      query.where(Arel.sql(conditions.join(" OR ")).to_s)
    end

    def filter_deleted(query)
      conditions = []

      ActionLog.public_resource_types.each do |resource_type|
        klass = resource_type.constantize

        condition = if klass.respond_to?(:not_deleted)
                      Arel.sql(
                        [
                          "decidim_action_logs.resource_type = '#{resource_type}'",
                          "decidim_action_logs.resource_id IN (#{Arel.sql(klass.not_deleted.select(:id).to_sql)})"
                        ].join(" AND ")
                      ).to_s
                    else
                      Arel.sql("decidim_action_logs.resource_type = '#{resource_type}'").to_s
                    end

        conditions << "(#{condition})"
      end

      query.where(Arel.sql(conditions.join(" OR ")).to_s)
    end
  end
end
