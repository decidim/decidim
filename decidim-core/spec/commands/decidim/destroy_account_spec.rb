# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccount do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed) }
    let(:valid) { true }
    let(:data) do
      {
        delete_reason: "I want to delete my account",
      }
    end

    let(:form) do
      form = double(
        delete_reason: data[:delete_reason],
        valid?: valid
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

      it "stores the deleted_at and delete_reason to the user" do
        command.call
        expect(user.reload.delete_reason).to eq(data[:delete_reason])
        expect(user.reload.deleted_at).not_to be_nil
      end

      it "generates a random email so the user cannot log in again" do
        allow(SecureRandom).to receive(:uuid).and_return("1234")
        command.call
        expect(user.reload.email).to eq("deleted-user-1234@example.org")
      end
    end
  end
end
