# frozen_string_literal: true

module Decidim
  # A class to search for recent activity performed in a Decidim Organization.
  # It is intended to be used in the user profile, to retrieve activity and
  # timeline for that user.
  #
  # It will return any action for a given resource, except `create` on resources
  # that implement the `Decidim::Publicable` concern to avoid leaking private
  # data.
  #
  # Possible options:
  #
  # :organization - the `Decidim::Organization` to scope to search. Required.
  # :user - an optional `Decidim::USer` that performed the activites
  # :follows - a collection of `Decidim::Follow` resources. It will return any
  #   activity affecting any of these resources, performed by any of them or
  #   contained in any of them as spaces.
  # :scopes - a collection of `Decidim::Scope`. It will return any activity that
  #   took place in any of those scopes.
  class ActivitySearch < Searchlight::Search
    # Needed by Searchlight, this is the base query that will be used to
    # append other criteria to the search.
    def base_query
      query = ActionLog
              .where(visibility: %w(public-only all))
              .where(organization: options.fetch(:organization))

      query = query.where(user: options[:user]) if options[:user]
      query = query.where(resource_type: options[:resource_name]) if options[:resource_name]

      query = filter_follows(query)
      filter_hidden(query)
    end

    # Overwrites the default Searchlight run method since we want to return
    # activities in an specific order but we need to set it at the end of the chain.
    def run
      super.order(created_at: :desc)
    end

    # Adds a constrain to filter by resource type(s).
    def search_resource_type
      if resource_types.include?(resource_type)
        scope_for(resource_type)
      else
        all_resources_scope
      end
    end

    # All the resource types that are eligible to be included as an activity.
    def resource_types
      @resource_types ||= %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Consultations::Question
        Decidim::Debates::Debate
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Surveys::Survey
        Decidim::Assembly
        Decidim::Consultation
        Decidim::Initiative
        Decidim::ParticipatoryProcess
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end

    private

    def publicable_resource_types
      @publicable_resource_types ||= resource_types.select { |klass| klass.constantize.column_names.include?("published_at") }
    end

    def scope_for(resource_type)
      if publicable_resource_types.include?(resource_type)
        query.where(resource_type: resource_type).where.not(action: "create")
      else
        query.where(resource_type: resource_type)
      end
    end

    def all_resources_scope
      query
        .where(
          "(action <> ? AND resource_type IN (?)) OR (resource_type IN (?))",
          "create",
          publicable_resource_types,
          (resource_types - publicable_resource_types)
        )
    end

    def filter_follows(query)
      follows = options[:follows]
      interesting_scopes = options[:scopes]
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

      conditions += interesting_scopes_conditions(interesting_scopes)

      return query if conditions.empty?

      chained_conditions = conditions.inject do |previous_condition, condition|
        next condition unless previous_condition

        previous_condition.or(condition)
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
      current_user_id = options.fetch(:current_user, nil)&.id.to_i
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
