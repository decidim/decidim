# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "Assemblies Participatory Space" do
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
      it "deletes assembly user role" do
        create(:assembly_user_role, user:)

        expect do
          command.call
        end.to change(AssemblyUserRole, :count).by(-1)
      end

      it "deletes assembly member" do
        create(:assembly_member, user:)

        expect do
          command.call
        end.to change(AssemblyMember, :count).by(-1)
      end
    end
  end
end
