# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261005130000_rename_participatory_process_phase_references"

describe RenameParticipatoryProcessPhaseReferences do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:old_type) { "Decidim::ParticipatoryProcessPhase" }
  let(:new_type) { "Decidim::ParticipatoryProcessPhase" }
  let!(:action_log) do
    columns = {
      decidim_organization_id: organization.id,
      user_id: user.id,
      user_type: "Decidim::User",
      resource_type: old_type,
      resource_id: 999_999,
      action: "create",
      visibility: "public-only",
      created_at: Time.current,
      updated_at: Time.current
    }
    ActiveRecord::Base.connection.execute(
      "INSERT INTO decidim_action_logs (#{columns.keys.join(", ")}) VALUES (#{columns.values.map { |v| ActiveRecord::Base.connection.quote(v) }.join(", ")})"
    )
    Decidim::ActionLog.find_by(id: ActiveRecord::Base.connection.select_value("SELECT max(id) FROM decidim_action_logs"))
  end
  let!(:other_action_log) { create(:action_log, user:, organization:) }
  let!(:version) do
    Version.create!(
      item_type: old_type,
      item_id: 999_999,
      event: "update",
      whodunnit: user.id.to_s,
      object: "{}",
      object_changes: "{}",
      created_at: Time.current
    )
  end
  let!(:other_version) do
    Version.create!(
      item_type: "Decidim::ParticipatoryProcess",
      item_id: 123,
      event: "update",
      whodunnit: user.id.to_s,
      object: "{}",
      object_changes: "{}",
      created_at: Time.current
    )
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  describe "#up" do
    it "renames action log references to the phase" do
      migrator.migrate(:up)

      expect(action_log.reload.resource_type).to eq(new_type)
      expect(Version.find(version.id).item_type).to eq(new_type)
    end

    it "keeps other action logs and versions intact" do
      migrator.migrate(:up)

      expect(other_action_log.reload.resource_type).not_to eq(new_type)
      expect(Version.find(other_version.id).item_type).to eq("Decidim::ParticipatoryProcess")
    end
  end

  describe "#down" do
    it "renames phase references back to the step" do
      migrator.migrate(:up)
      migrator.migrate(:down)

      expect(action_log.reload.resource_type).to eq(old_type)
      expect(Version.find(version.id).item_type).to eq(old_type)
    end
  end
end
