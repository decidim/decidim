# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:remove_deleted_users_left_data", type: :task, versioning: true do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed) }
  let(:other_user) { create(:user, :confirmed) }
  let(:deleted_user) { create(:user, :confirmed, :deleted) }

  before do
    create(:oauth_access_token, resource_owner_id: deleted_user.id)
    create(:oauth_access_grant, organization: user.organization, resource_owner_id: deleted_user.id)
    create(:notification, user: deleted_user)
    create(:reminder, user: deleted_user)
    create(:private_export, attached_to: deleted_user)
    create(:identity, user: deleted_user)
    create(:authorization, :granted, user: deleted_user, unique_id: "12345678X")
    create(:follow, followable: deleted_user, user: user)
    create(:follow, followable: user, user: deleted_user)
    create(:participatory_space_private_user, user: deleted_user)

    create(:oauth_access_token, resource_owner_id: user.id)
    create(:identity, user:)
    create(:authorization, :granted, user: user, unique_id: "12345678X")
    create(:follow, followable: user, user: other_user)
    create(:follow, followable: other_user, user:)
    create(:private_export, attached_to: user)
  end

  context "when the task is performed" do
    it "deletes the access tokens of deleted user" do
      expect { task.execute }.to change(Doorkeeper::AccessToken, :count).by(-1)
    end

    it "deletes the follows of the deleted user" do
      expect { task.execute }.to change(Decidim::Follow, :count).by(-2)
    end

    it "deletes the access grants of deleted user" do
      expect { task.execute }.to change(Doorkeeper::AccessGrant, :count).by(-1)
    end

    it "deletes the notifications of deleted user" do
      expect { task.execute }.to change(Decidim::Notification, :count).by(-1)
    end

    it "deletes the reminders of deleted user" do
      expect { task.execute }.to change(Decidim::Reminder, :count).by(-1)
    end

    it "deletes the authorizations of deleted user" do
      expect { task.execute }.to change(Decidim::Authorization, :count).by(-1)
    end

    it "deletes the versions of deleted user" do
      task.execute
      expect(deleted_user.reload.versions.count).to eq(0)
    end

    it "deletes the private exports of deleted user" do
      expect { task.execute }.to change(Decidim::PrivateExport, :count).by(-1)
    end

    it "deletes the identities of deleted user" do
      expect { task.execute }.to change(Decidim::Identity, :count).by(-1)
    end

    it "deletes the participatory space private user of deleted user" do
      expect { task.execute }.to change(Decidim::ParticipatorySpacePrivateUser, :count).by(-1)
    end
  end

  context "when task is performed for not deleted users" do
    it "does not affects the user records" do
      expect { task.execute }.not_to(change { user.reload.versions.count })
      expect { task.execute }.not_to(change { user.reload.access_tokens.count })
      expect { task.execute }.not_to(change { user.reload.identities.count })
      expect { task.execute }.not_to(change { user.reload.follows.count })
      expect { task.execute }.not_to(change { user.reload.private_exports.count })
      expect do
        task.execute
      end.not_to(change { Decidim::Authorization.where(decidim_user_id: user.id).count })
    end
  end
end
