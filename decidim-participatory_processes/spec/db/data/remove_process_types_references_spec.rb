# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260104094929_remove_process_types_references"

describe RemoveProcessTypesReferences do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:another_user) { create(:user, organization:) }
  let(:process_type) { "Decidim::ParticipatoryProcessType" }
  let(:draft_id) { 999_999 }

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  describe "#up" do
    context "with notifications" do
      let!(:notification) do
        notification = create(:notification, user:)
        notification.update_column(:decidim_resource_type, process_type) # rubocop:disable Rails/SkipsModelValidations
        notification.update_column(:decidim_resource_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
        notification
      end

      let!(:other_notification) do
        create(:notification, user:)
      end

      it "deletes notifications referencing participatory process types" do
        expect(Decidim::Notification.where(decidim_resource_type: process_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::Notification.where(decidim_resource_type: process_type).count).to eq(0)
      end

      it "keeps other notifications intact" do
        migrator.migrate(:up)
        expect(Decidim::Notification.find_by(id: other_notification.id)).to be_present
      end
    end

    context "with action logs" do
      let!(:action_log) do
        table = "decidim_action_logs"
        columns = {
          decidim_organization_id: organization.id,
          user_id: user.id,
          user_type: "Decidim::User",
          resource_type: process_type,
          resource_id: draft_id,
          action: "create",
          visibility: "public-only",
          created_at: Time.current,
          updated_at: Time.current
        }
        ActiveRecord::Base.connection.execute(
          "INSERT INTO #{table} (#{columns.keys.join(", ")}) VALUES (#{columns.values.map { |v| ActiveRecord::Base.connection.quote(v) }.join(", ")})"
        )
        Decidim::ActionLog.last
      end

      let!(:other_action_log) do
        create(:action_log, user: another_user, organization:)
      end

      it "deletes action logs referencing participatory process types" do
        expect(Decidim::ActionLog.where(resource_type: process_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::ActionLog.where(resource_type: process_type).count).to eq(0)
      end

      it "keeps other action logs" do
        migrator.migrate(:up)
        expect(Decidim::ActionLog.find_by(id: other_action_log.id)).to be_present
      end
    end

    context "with paper trail versions" do
      let!(:version_for_draft) do
        Version.create!(
          item_type: process_type,
          item_id: draft_id,
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

      it "deletes paper trail versions for participatory process types" do
        expect(Version.where(item_type: process_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Version.where(item_type: process_type).count).to eq(0)
      end

      it "keeps other versions intact" do
        migrator.migrate(:up)
        expect(Version.find_by(id: other_version.id)).to be_present
      end
    end

    context "when tables are empty" do
      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end
  end
end
