# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261014090000_update_timeline_entry_references"

describe UpdateTimelineEntryReferences do
  let(:migrator) do
    described_class.new.tap do |migration|
      migration.verbose = false
    end
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  describe "#up" do
    let!(:timeline_action_log) do
      create_action_log("Decidim::Accountability::TimelineEntry")
    end
    let!(:other_action_log) do
      create_action_log("Decidim::Accountability::Result")
    end
    let!(:timeline_version) do
      Version.create!(
        item_type: "Decidim::Accountability::TimelineEntry",
        item_id: 99_999,
        event: "update",
        whodunnit: user.id.to_s,
        object: "{}",
        object_changes: "{}",
        created_at: Time.current
      )
    end
    let!(:other_version) do
      Version.create!(
        item_type: "Decidim::Accountability::Result",
        item_id: 99_998,
        event: "update",
        whodunnit: user.id.to_s,
        object: "{}",
        object_changes: "{}",
        created_at: Time.current
      )
    end

    it "replaces legacy timeline entry references with milestone references" do
      migrator.migrate(:up)

      expect(Decidim::ActionLog.find(timeline_action_log.id).resource_type).to eq("Decidim::Accountability::Milestone")
      expect(Version.find(timeline_version.id).item_type).to eq("Decidim::Accountability::Milestone")
    end

    it "leaves other references unchanged" do
      migrator.migrate(:up)

      expect(Decidim::ActionLog.find(other_action_log.id).resource_type).to eq("Decidim::Accountability::Result")
      expect(Version.find(other_version.id).item_type).to eq("Decidim::Accountability::Result")
    end

    it "is safe to run more than once" do
      2.times { migrator.migrate(:up) }

      expect(Decidim::ActionLog.where(resource_type: "Decidim::Accountability::Milestone").count).to eq(1)
      expect(Version.where(item_type: "Decidim::Accountability::Milestone").count).to eq(1)
    end
  end

  describe "#down" do
    it "is irreversible" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end

  private

  def create_action_log(resource_type)
    Decidim::ActionLog.insert_all([
                                     {
                                       decidim_organization_id: organization.id,
                                       user_id: user.id,
                                       user_type: "Decidim::User",
                                       resource_type:,
                                       resource_id: 99_999,
                                       action: "create",
                                       visibility: "public-only",
                                       extra: {},
                                       created_at: Time.current,
                                       updated_at: Time.current
                                     }
                                   ])
    Decidim::ActionLog.order(:id).last
  end
end
