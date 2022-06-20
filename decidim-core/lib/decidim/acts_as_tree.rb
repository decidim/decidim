# frozen_string_literal: true

module Decidim
  module ActsAsTree
    extend ActiveSupport::Concern

    included do
      @parent_item_foreign_key = :parent_id
    end

    class_methods do
      def parent_item_foreign_key(name = nil)
        return @parent_item_foreign_key unless name

        @parent_item_foreign_key = name
      end

      def tree_for(item)
        where(Arel.sql("#{table_name}.id IN (#{tree_sql_for(item)})")).order("#{table_name}.id")
      end

      def tree_sql_for(item)
        <<-SQL.squish
        WITH RECURSIVE search_tree(id, path) AS (
          SELECT id, ARRAY[id]
          FROM #{table_name}
          WHERE id = #{item.id}
            UNION ALL
          SELECT #{table_name}.id, path || #{table_name}.id
            FROM search_tree
          JOIN #{table_name} ON #{table_name}.#{parent_item_foreign_key} = search_tree.id
            WHERE NOT #{table_name}.id = ANY(path)
        )
        SELECT id FROM search_tree ORDER BY path
        SQL
      end
    end

    def descendants
      @descendants ||= self_and_descendants.where.not(id: id)
    end

    def self_and_descendants
      @self_and_descendants ||= self.class.tree_for(self)
    end
  end
end
