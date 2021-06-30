# frozen_string_literal: true

class FixBlockedUserNamesInActionLog < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        execute_query(
          update_query(
            "coalesce(decidim_users.extended_data->>'user_name', decidim_users.name)"
          )
        )
      end

      dir.down do
        execute_query(update_query("'Blocked user'::text"))
      end
    end
  end

  private

  def update_query(user_name_replacement)
    <<~SQL.squish
      UPDATE decidim_action_logs
        SET extra = jsonb_set(
          decidim_action_logs.extra,
          '{resource,title}',
          to_jsonb(#{user_name_replacement})
        )
        FROM decidim_users
        WHERE decidim_users.id = decidim_action_logs.resource_id
        AND decidim_action_logs.resource_type = $1 AND decidim_action_logs.action = $2
    SQL
  end

  def execute_query(query)
    rawconn.prepare("statement1", query)
    rawconn.exec_prepared("statement1", ["Decidim::User", "block"])
    rawconn.exec("DEALLOCATE statement1")
  end

  def rawconn
    ActiveRecord::Base.connection.raw_connection
  end
end
