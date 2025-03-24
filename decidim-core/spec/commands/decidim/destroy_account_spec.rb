# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccount do
    let(:command) { described_class.new(form) }
    let(:user) { create(:user, :confirmed) }
    let!(:identity) { create(:identity, user:) }
    let(:valid) { true }
    let(:data) do
      {
        delete_reason: "I want to delete my account"
      }
    end

    let(:form) do
      form = double(
        delete_reason: data[:delete_reason],
        valid?: valid,
        current_user: user
      )

      form
    end

    context "when invalid" do
      let(:valid) { false }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      let(:valid) { true }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "changes the auth salt to invalidate all other sessions" do
        old_salt = user.authenticatable_salt
        command.call
        expect(user.reload.authenticatable_salt).not_to eq(old_salt)
      end

      it "stores the deleted_at and delete_reason to the user" do
        command.call
        expect(user.reload.delete_reason).to eq(data[:delete_reason])
        expect(user.reload.deleted_at).not_to be_nil
      end

      it "set name, nickname, personal_url, about and email to blank string" do
        command.call
        user.reload
        expect(user.name).to eq("")
        expect(user.nickname).to eq("")
        expect(user.email).to eq("")
        expect(user.personal_url).to eq("")
        expect(user.about).to eq("")
        expect(user.notifications_sending_frequency).to eq("none")
      end

      it "destroys the current user avatar" do
        command.call
        expect(user.reload.avatar).not_to be_present
      end

      it "deletes user's identities" do
        expect do
          command.call
        end.to change(Identity, :count).by(-1)
      end

      it "deletes the follows" do
        other_user = create(:user)
        create(:follow, followable: user, user: other_user)
        create(:follow, followable: other_user, user:)

        expect do
          command.call
        end.to change(Follow, :count).by(-2)
      end

      it "deletes participatory space private user" do
        create(:participatory_space_private_user, user:)

        expect do
          command.call
        end.to change(ParticipatorySpacePrivateUser, :count).by(-1)
      end

      context "when user is admin" do
        let(:user) { create(:user, :confirmed, :admin) }

        it "removes admin role" do
          command.call
          expect(user.reload.admin).to be_falsey
        end
      end
    end
  end
end
