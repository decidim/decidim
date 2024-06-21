# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "Conference Participatory Space" do
    let(:command) { Decidim::DestroyAccount.new(form) }

    let(:user) { create(:user, :confirmed) }
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

    context "when an account is removed" do
      it "deletes conference user role" do
        create(:conference_user_role, user:)

        expect do
          command.call
        end.to change(ConferenceUserRole, :count).by(-1)
      end

      it "deletes conference speaker" do
        create(:conference_speaker, user:)

        expect do
          command.call
        end.to change(ConferenceSpeaker, :count).by(-1)
      end
    end
  end
end
