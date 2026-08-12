# frozen_string_literal: true

require "spec_helper"

describe Decidim::DeleteRevokedAuthorizationsVersionsJob, versioning: true do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:user1) { create(:user, organization:) }
  let(:user2) { create(:user, organization:) }

  let(:recently_deleted_authorization) { create(:authorization, name: "example", granted_at: Time.current, user: user1) }
  let(:recently_deleted_authorization_id) { recently_deleted_authorization.id }
  let(:old_deleted_authorization) { create(:authorization, name: "example", granted_at: Time.current, user: user2) }
  let(:old_deleted_authorization_id) { old_deleted_authorization.id }

  let(:versions) { PaperTrail::Version.where(item_type: described_class.item_type) }

  before do
    travel(-30.days) do
      old_deleted_authorization_id
      old_deleted_authorization.destroy!
    end

    recently_deleted_authorization_id
    recently_deleted_authorization.destroy!
  end

  it_behaves_like "delete old versions job"

  it "deletes the versions for deleted authorizations created before the cutoff date" do
    expect(versions.where(item_id: old_deleted_authorization_id).count).to eq(2)
    expect(versions.where(item_id: recently_deleted_authorization_id).count).to eq(2)
    perform_enqueued_jobs { subject.perform_later(20) }
    expect(versions.where(item_id: old_deleted_authorization_id).count).to eq(0)
    expect(versions.where(item_id: recently_deleted_authorization_id).count).to eq(2)
  end

  context "with existing authorization" do
    let(:existing_old_authorization) { create(:authorization, name: "example", granted_at: Time.current, user: user1) }

    before do
      travel(-30.days) do
        existing_old_authorization
      end
    end

    it "does not delete data for existing authorizations" do
      expect(versions.where(item_id: existing_old_authorization.id).count).to eq(1)
      perform_enqueued_jobs { subject.perform_later(20) }
      expect(versions.where(item_id: existing_old_authorization.id).count).to eq(1)
    end
  end
end
