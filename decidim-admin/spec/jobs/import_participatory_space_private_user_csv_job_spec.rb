# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportParticipatorySpacePrivateUserCsvJob do
      let!(:email) { "my_user@example.org" }
      let!(:user_name) { "My User Name" }
      let(:user) { create(:user, :admin, organization:) }
      let(:organization) { create(:organization) }
      let(:privatable_to) { create(:participatory_process, organization:) }

      context "when the participatory space private user not exists" do
        it "delegates the work to a command" do
          expect(Decidim::Admin::CreateParticipatorySpacePrivateUser).to receive(:call)
          described_class.perform_now(email, user_name, privatable_to, user)
        end
      end
    end
  end
end
