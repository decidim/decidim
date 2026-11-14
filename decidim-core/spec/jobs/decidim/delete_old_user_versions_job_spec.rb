# frozen_string_literal: true

require "spec_helper"

describe Decidim::DeleteOldUserVersionsJob, versioning: true do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:recently_deleted_user) { create(:user, organization:) }
  let(:old_deleted_user) { create(:user, organization:, created_at: 60.days.ago) }
  let(:versions) { PaperTrail::Version.where(item_type: described_class.item_type) }

  before do
    travel(-30.days) do
      Decidim::DestroyAccount.call(destroy_form_for(old_deleted_user))
    end

    Decidim::DestroyAccount.call(destroy_form_for(recently_deleted_user))
  end

  it_behaves_like "delete old versions job"

  it "deletes the versions for deleted users created before the cutoff date" do
    expect(versions.where(item_id: old_deleted_user.id).count).to eq(3)
    expect(versions.where(item_id: recently_deleted_user.id).count).to eq(3)
    perform_enqueued_jobs { subject.perform_later(20) }
    expect(versions.where(item_id: old_deleted_user.id).count).to eq(0)
    expect(versions.where(item_id: recently_deleted_user.id).count).to eq(3)
  end

  context "with existing user" do
    let(:existing_old_user) { create(:user, organization:, created_at: 60.days.ago) }

    before do
      travel(-30.days) do
        existing_old_user
      end
    end

    it "does not delete data for existing users" do
      expect(versions.where(item_id: existing_old_user.id).count).to eq(1)
      perform_enqueued_jobs { subject.perform_later(20) }
      expect(versions.where(item_id: existing_old_user.id).count).to eq(1)
    end
  end

  def destroy_form_for(user)
    double(valid?: true, delete_reason: "Testing", current_user: user)
  end
end
