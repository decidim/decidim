# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260224210316_remove_collaborative_drafts_references"

describe RemoveCollaborativeDraftsReferences do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:another_user) { create(:user, organization:) }

  let(:collaborative_draft_type) { "Decidim::Proposals::CollaborativeDraft" }
  let(:collaborative_draft_collaborator_request_type) { "Decidim::Proposals::CollaborativeDraftCollaboratorRequest" }
  let(:draft_id) { 999_999 }
  let(:collaborator_request_id) { 888_888 }

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  describe "#up" do
    context "with notifications" do
      let!(:notification) do
        notification = create(:notification, user:)
        notification.update_column(:decidim_resource_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
        notification.update_column(:decidim_resource_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
        notification
      end

      let!(:other_notification) do
        create(:notification, user:)
      end

      it "deletes notifications referencing collaborative drafts" do
        expect(Decidim::Notification.where(decidim_resource_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::Notification.where(decidim_resource_type: collaborative_draft_type).count).to eq(0)
      end

      it "keeps other notifications intact" do
        migrator.migrate(:up)
        expect(Decidim::Notification.find_by(id: other_notification.id)).to be_present
      end
    end

    context "with follows" do
      let!(:follow) do
        follow = create(:follow, user:)
        follow.update_column(:decidim_followable_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
        follow.update_column(:decidim_followable_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
        follow
      end

      let!(:other_follow) do
        create(:follow, user: another_user)
      end

      it "deletes follows referencing collaborative drafts" do
        expect(Decidim::Follow.where(decidim_followable_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::Follow.where(decidim_followable_type: collaborative_draft_type).count).to eq(0)
      end

      it "keeps other follows" do
        migrator.migrate(:up)
        expect(Decidim::Follow.find_by(id: other_follow.id)).to be_present
      end
    end

    context "with coauthorships" do
      let!(:coauthorship) do
        coauthorship = create(:coauthorship)
        coauthorship.update_column(:coauthorable_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
        coauthorship.update_column(:coauthorable_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
        coauthorship
      end

      let!(:other_coauthorship) do
        create(:coauthorship)
      end

      it "deletes coauthorships referencing collaborative drafts" do
        expect(Decidim::Coauthorship.where(coauthorable_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::Coauthorship.where(coauthorable_type: collaborative_draft_type).count).to eq(0)
      end

      it "keeps other coauthorships" do
        migrator.migrate(:up)
        expect(Decidim::Coauthorship.find_by(id: other_coauthorship.id)).to be_present
      end
    end

    context "with action logs" do
      let!(:action_log) do
        table = "decidim_action_logs"
        columns = {
          decidim_organization_id: organization.id,
          user_id: user.id,
          user_type: "Decidim::User",
          resource_type: collaborative_draft_type,
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

      it "deletes action logs referencing collaborative drafts" do
        expect(Decidim::ActionLog.where(resource_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::ActionLog.where(resource_type: collaborative_draft_type).count).to eq(0)
      end

      it "keeps other action logs" do
        migrator.migrate(:up)
        expect(Decidim::ActionLog.find_by(id: other_action_log.id)).to be_present
      end
    end

    context "with moderations (reports)" do
      let!(:moderation) do
        moderation = create(:moderation)
        moderation.update_column(:decidim_reportable_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
        moderation.update_column(:decidim_reportable_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
        moderation
      end

      let!(:other_moderation) do
        create(:moderation)
      end

      it "deletes moderations referencing collaborative drafts" do
        expect(Decidim::Moderation.where(decidim_reportable_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::Moderation.where(decidim_reportable_type: collaborative_draft_type).count).to eq(0)
      end

      it "keeps other moderations" do
        migrator.migrate(:up)
        expect(Decidim::Moderation.find_by(id: other_moderation.id)).to be_present
      end
    end

    context "with comments" do
      let!(:comment) do
        comment = create(:comment)
        comment.update_column(:decidim_commentable_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
        comment.update_column(:decidim_commentable_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
        comment
      end

      let!(:other_comment) do
        create(:comment)
      end

      it "deletes comments referencing collaborative drafts" do
        expect(Decidim::Comments::Comment.where(decidim_commentable_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Decidim::Comments::Comment.where(decidim_commentable_type: collaborative_draft_type).count).to eq(0)
      end

      it "keeps other comments" do
        migrator.migrate(:up)
        expect(Decidim::Comments::Comment.find_by(id: other_comment.id)).to be_present
      end
    end

    context "with paper trail versions" do
      let!(:version_for_draft) do
        Version.create!(
          item_type: collaborative_draft_type,
          item_id: draft_id,
          event: "update",
          whodunnit: user.id.to_s,
          object: "{}",
          object_changes: "{}",
          created_at: Time.current
        )
      end

      let!(:version_for_collaborator_request) do
        Version.create!(
          item_type: collaborative_draft_collaborator_request_type,
          item_id: collaborator_request_id,
          event: "update",
          whodunnit: user.id.to_s,
          object: "{}",
          object_changes: "{}",
          created_at: Time.current
        )
      end

      let!(:other_version) do
        Version.create!(
          item_type: "Decidim::Proposal",
          item_id: 123,
          event: "update",
          whodunnit: user.id.to_s,
          object: "{}",
          object_changes: "{}",
          created_at: Time.current
        )
      end

      it "deletes paper trail versions for collaborative drafts" do
        expect(Version.where(item_type: collaborative_draft_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Version.where(item_type: collaborative_draft_type).count).to eq(0)
      end

      it "deletes paper trail versions for collaborator requests" do
        expect(Version.where(item_type: collaborative_draft_collaborator_request_type).count).to eq(1)
        migrator.migrate(:up)
        expect(Version.where(item_type: collaborative_draft_collaborator_request_type).count).to eq(0)
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
