# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "ParticipatoryProcess Participatory Space" do
    let(:command) { Decidim::DestroyAccount.new(user, form) }

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
        valid?: valid
      )

      form
    end

    context "when an account is removed" do
      it "deletes participatory process user role" do
        create(:participatory_process_user_role, user:)

        expect do
          command.call
        end.to change(ParticipatoryProcessUserRole, :count).by(-1)
      end
    end
  end
end
