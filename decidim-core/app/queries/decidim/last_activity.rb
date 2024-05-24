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

    def filter_spaces(query)
      current_user_id = current_user&.id.to_i
      Decidim.participatory_space_manifests.map do |manifest|
        klass = manifest.model_class_name.constantize
        next unless klass.include?(Decidim::HasPrivateUsers)

        table = klass.table_name
        query = query.joins(
          Arel.sql(
            <<~SQL.squish
              LEFT JOIN #{table}
                ON decidim_action_logs.participatory_space_type = '#{manifest.model_class_name}'
                AND #{table}.id = decidim_action_logs.participatory_space_id
              LEFT JOIN decidim_participatory_space_private_users AS #{manifest.name}_private_users
                ON #{manifest.name}_private_users.privatable_to_type = '#{manifest.model_class_name}'
                AND #{table}.id = #{manifest.name}_private_users.privatable_to_id
                AND #{table}.private_space = 't'
            SQL
          ).to_s
        ).where(
          Arel.sql(
            <<~SQL.squish
              #{table}.id IS NULL OR
              #{table}.private_space = 'f' OR
              #{manifest.name}_private_users.decidim_user_id = #{current_user_id}
            SQL
          ).to_s
        )
      end

      query
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
