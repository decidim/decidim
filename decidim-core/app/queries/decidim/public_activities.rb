# frozen_string_literal: true

module Decidim
  # This query finds the public ActionLog entries that can be shown in the
  # participant views of the application within a Decidim Organization. It is
  # intended to be used in the user profile, to retrieve activity and timeline
  # for that user.
  #
  # This will create the base query for the activities but the resulting query
  # needs to be scoped with either `with_resource_type` or
  # `with_new_resource_type` in order to avoid leaking private data.
  #
  # Possible options:
  #
  # :resource_name - an optional name for a resource for searching only that
  #    type of resources.
  # :user - an optional `Decidim::User` that performed the activites
  # :current_user - an optional `Decidim::User` for defining whether to show the
  #   private log entries that relate to the current user.
  # :follows - a collection of `Decidim::Follow` resources. It will return any
  #   activity affecting any of these resources, performed by any of them or
  #   contained in any of them as spaces.
  # :scopes - a collection of `Decidim::Scope`. It will return any activity that
  #   took place in any of those scopes.
  class PublicActivities < Decidim::Query
    def initialize(organization, options = {})
      @organization = organization
      @resource_name = options[:resource_name]
      @user = options[:user]
      @current_user = options[:current_user]
      @follows = options[:follows]
      @scopes = options[:scopes]
    end

    def query
      query = ActionLog
              .where(visibility: visibility)
              .where(organization: organization)

      query = query.where(user: user) if user
      query = query.where(resource_type: resource_name) if resource_name.present?

      query = filter_follows(query)
      query = filter_hidden(query)

      query.order(created_at: :desc)
    end

    private

    attr_reader :organization, :resource_name, :user, :current_user, :follows, :scopes

    def visibility
      %w(public-only all)
    end

    def filter_follows(query)
      conditions = []

      if follows.present?
        conditions += follows.group_by(&:decidim_followable_type).map do |type, grouped_follows|
          Decidim::ActionLog.arel_table[:resource_type].eq(type).and(
            Decidim::ActionLog.arel_table[:resource_id].in(grouped_follows.map(&:decidim_followable_id))
          )
        end

        conditions += followed_users_conditions(follows)
        conditions += followed_spaces_conditions(follows)
      end

      conditions += interesting_scopes_conditions(scopes)

      return query if conditions.empty?

      chained_conditions = conditions.inject do |previous_condition, condition|
        previous_condition.present? ? previous_condition.or(condition) : condition
      end

      query.where(chained_conditions)
    end

    def filter_hidden(query)
      # Filter out the items that have been moderated.
      query = query.joins(
        <<~SQL.squish
          LEFT JOIN decidim_moderations
            ON decidim_moderations.decidim_reportable_type = decidim_action_logs.resource_type
            AND decidim_moderations.decidim_reportable_id = decidim_action_logs.resource_id
            AND decidim_moderations.hidden_at IS NOT NULL
        SQL
      ).where(decidim_moderations: { id: nil })

      # Filter out the private space items that should not be visible for the
      # current user.
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

    def followed_users_conditions(follows)
      followed_users = follows.where(decidim_followable_type: "Decidim::UserBaseEntity")
      return [] if followed_users.empty?

      [Decidim::ActionLog.arel_table[:decidim_user_id].in(followed_users.map(&:decidim_followable_id))]
    end

    def followed_spaces_conditions(follows)
      followed_spaces = follows.where(decidim_followable_type: participatory_space_classes)
      return [] if followed_spaces.empty?

      followed_spaces.group_by(&:decidim_followable_type).map do |type, grouped_follows|
        Decidim::ActionLog.arel_table[:participatory_space_type].eq(type).and(
          Decidim::ActionLog.arel_table[:participatory_space_id].in(grouped_follows.map(&:decidim_followable_id))
        )
      end
    end

    def interesting_scopes_conditions(interesting_scopes)
      return [] if interesting_scopes.blank?

      [Decidim::ActionLog.arel_table[:decidim_scope_id].in(interesting_scopes.map(&:id))]
    end

    def participatory_space_classes
      Decidim.participatory_space_manifests.map(&:model_class_name)
    end
  end
end
