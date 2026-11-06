# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261106090000_rename_proposal_state_records_to_proposal_statuses"

describe RenameProposalStateRecordsToProposalStatuses do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:proposal) { create(:proposal) }
  let!(:action_log) do
    create(:action_log, resource: proposal).tap do |log|
      # rubocop:disable-next Rails/SkipsModelValidations
      Decidim::ActionLog.where(id: log.id).update_all(resource_type: "Decidim::Proposals::ProposalState")
    end
  end
  let!(:status_version) do
    PaperTrail::Version.create!(item: proposal, event: "update", object_changes: {}).tap do |version|
      PaperTrail::Version.where(id: version.id).update_all(item_type: "Decidim::Proposals::ProposalState") # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def create_changeset_version(changeset)
    PaperTrail::Version.create!(
      item: proposal,
      event: "update",
      object_changes: changeset
    )
  end

  it "renames the action log and version types" do
    migrator.migrate(:up)

    expect(action_log.reload.resource_type).to eq("Decidim::Proposals::ProposalStatus")
    expect(status_version.reload.item_type).to eq("Decidim::Proposals::ProposalStatus")

    migrator.migrate(:down)

    expect(action_log.reload.resource_type).to eq("Decidim::Proposals::ProposalState")
    expect(status_version.reload.item_type).to eq("Decidim::Proposals::ProposalState")
  end

  it "renames the proposal changeset keys and maps the legacy state indexes" do
    version = create_changeset_version(
      "state" => [nil, 20],
      "decidim_proposals_proposal_state_id" => [nil, 3],
      "state_published_at" => [nil, "2026-01-01"]
    )

    migrator.migrate(:up)

    expect(version.reload.object_changes).to eq(
      "status" => [nil, "accepted"],
      "decidim_proposals_proposal_status_id" => [nil, 3],
      "status_published_at" => [nil, "2026-01-01"]
    )

    migrator.migrate(:down)

    expect(version.reload.object_changes).to eq(
      "state" => [nil, "accepted"],
      "decidim_proposals_proposal_state_id" => [nil, 3],
      "state_published_at" => [nil, "2026-01-01"]
    )
  end

  it "leaves unrelated versions untouched" do
    version = create_changeset_version("title" => %w(before after))

    expect { migrator.migrate(:up) }.not_to(change { version.reload.object_changes })
  end
end
