# frozen_string_literal: true

class RenameProposalAnswerTemplateFieldValues < ActiveRecord::Migration[7.0]
  def up
    rename_field_value("proposal_state_id", "proposal_status_id")
  end

  def down
    rename_field_value("proposal_status_id", "proposal_state_id")
  end

  private

  def rename_field_value(from, to)
    execute <<~SQL.squish
      UPDATE decidim_templates_templates
      SET field_values = (field_values::jsonb - '#{from}') || jsonb_build_object('#{to}', field_values::jsonb -> '#{from}')
      WHERE target = 'proposal_answer'
        AND field_values::jsonb ? '#{from}'
    SQL
  end
end
