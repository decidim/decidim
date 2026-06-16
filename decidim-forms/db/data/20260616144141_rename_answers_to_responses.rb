# frozen_string_literal: true

class RenameAnswersToResponses < ActiveRecord::Migration[7.2]
  class Attachment < ApplicationRecord
    self.table_name = "decidim_attachments"
  end

  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    Attachment.where(attached_to_type: "Decidim::Forms::Answer").update_all(attached_to_type: "Decidim::Forms::Response")
    ActionLog.where(resource_type: "Decidim::Forms::Answer").update_all(resource_type: "Decidim::Forms::Response")
    Version.where(item_type: "Decidim::Forms::Answer").update_all(item_type: "Decidim::Forms::Response")
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    Attachment.where(attached_to_type: "Decidim::Forms::Response").update_all(attached_to_type: "Decidim::Forms::Answer")
    ActionLog.where(resource_type: "Decidim::Forms::Response").update_all(resource_type: "Decidim::Forms::Answer")
    Version.where(item_type: "Decidim::Forms::Response").update_all(item_type: "Decidim::Forms::Answer")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
