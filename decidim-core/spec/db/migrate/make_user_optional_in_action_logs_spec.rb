# frozen_string_literal: true

require "spec_helper"
require_relative "../../../db/migrate/20261007090000_make_user_optional_in_action_logs"

describe "MakeUserOptionalInActionLogs", type: :migration do
  let(:migration) { MakeUserOptionalInActionLogs.new }

  describe "#migrate :up" do
    it "allows action logs without a user" do
      migration.migrate(:up)

      expect do
        create(:action_log, user: nil, user_id: nil, user_type: nil, organization: create(:organization))
      end.to change(Decidim::ActionLog, :count).by(1)
    end
  end

  describe "#migrate :down" do
    it "raises IrreversibleMigration" do
      expect { migration.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
