# frozen_string_literal: true

module Decidim
  module Messaging
    # A class used to find a conversation between the given set of users and
    # only between those users. There is always only a single conversation
    # between the same set of users.
    class ConversationBetween < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried object.
      #
      # @param users [Array<Decidim::User>] (see #initialize)
      # @return [Decidim::Messaging::Conversation, nil] (see #find)
      def self.for(users)
        new(users).find
      end

      # Initializes the query object.
      #
      # @param users [Array<Decidim::User>] A list of users for which to find
      #   the conversation.
      def initialize(users)
        @users = users
      end

      # Returns all conversations where all of the users are part of and only
      # these users. There is always only one conversation between the same set
      # of users.
      #
      # @return [ActiveRecord::Relation] The query for conversation(s) between
      #   the set of users or nil if not found. The `find` method will fetch the
      #   first result as there is only one result.
      def query
        join_table = Arel::Table.new("participants")
        subquery = Arel::Nodes::As.new(groupped_conversations.arel, join_table)

        join_condition = Conversation.arel_table[:id].eq(join_table[:id])

        join_query =
          Conversation
          .arel_table
          .join(subquery, Arel::Nodes::InnerJoin).on(join_condition)

        Conversation
          .joins(join_query.join_sources)
          .where("participants.participant_ids = ARRAY[?]::bigint[]", sorted_user_ids)
      end

      # Finds the first record from the query result, as there is always only
      # one record returned.
      #
      # @return [Decidim::Messaging::Conversation, nil] The conversation between
      #   the set of users or nil if not found.
      def find
        query.first
      end

      private

      attr_reader :users

      # Sorts the user IDs for the final query as they should be always in
      # sorted order for the query to work. The `groupped_conversations` method
      # will return the participant IDs sorted.
      #
      # @return [Array<Integer>]
      def sorted_user_ids
        users.map(&:id).sort
      end

      # Generates the following query for all participants in a conversation:
      #   SELECT
      #       c.id,
      #       CAST(ARRAY_AGG(p.decidim_participant_id ORDER BY p.decidim_participant_id) AS bigint[])
      #     FROM decidim_messaging_conversations c
      #     INNER JOIN decidim_messaging_participations p
      #       ON p.decidim_conversation_id = c.id
      #     GROUP BY c.id
      #
      # Returns the following kind of table where we can match the exact
      # participants in all conversations:
      #   id | participant_ids
      #   --------------------
      #    1 | {1,2}
      #    2 | {3,4}
      #
      # @return [ActiveRecord::Relation]
      def groupped_conversations
        participants_table = Participation.arel_table
        participants_column = participants_table[:decidim_participant_id]

        order_clause = Arel::Nodes::InfixOperation.new(
          "",
          Arel::Nodes::SqlLiteral.new("ORDER BY"),
          participants_column.asc
        )
        array_agg = Arel::Nodes::NamedFunction.new(
          "ARRAY_AGG",
          [Arel::Nodes::InfixOperation.new("", participants_column, order_clause)]
        )

        cast_operation = Arel::Nodes::InfixOperation.new(
          "AS",
          array_agg,
          Arel.sql("bigint[]")
        )
        cast = Arel::Nodes::NamedFunction.new("CAST", [cast_operation])

        Conversation
          .where(id: candidate_conversations)
          .joins(:participations)
          .group(:id)
          .select(:id, cast.as("participant_ids"))
      end

      def candidate_conversations
        Conversation.joins(:participations).where(decidim_messaging_participations: { decidim_participant_id: users.first.id })
      end
    end
  end
end
