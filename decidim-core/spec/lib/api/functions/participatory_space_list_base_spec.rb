# frozen_string_literal: true

require "spec_helper"

module Decidim::Core
  describe ParticipatorySpaceListBase do
    subject { described_class.new(manifest: process1.manifest).call(nil, arguments, context) }

    let(:organization) { create(:organization) }
    let!(:process1) { create(:participatory_process, organization:) }
    let!(:process2) { create(:participatory_process, organization:) }
    let!(:process3) { create(:participatory_process, organization:) }
    let!(:restricted_process) { create(:participatory_process, :restricted, organization:) }
    let(:user) { nil }
    let(:context) { { current_organization: organization, current_user: user } }
    let(:arguments) { {} }

    it "returns the public spaces when the user is not logged in" do
      expect(subject).to include(process1, process2, process3)
      expect(subject).not_to include(restricted_process)
    end

    context "with admin user" do
      let(:user) { create(:user, :confirmed, :admin, organization:) }

      it "returns all spaces including the restricted space" do
        expect(subject).to include(process1, process2, process3, restricted_process)
      end
    end

    context "with a restricted space participant" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:member) { create(:member, participatory_space: restricted_process, user:) }

      it "returns all spaces including the restricted space" do
        expect(subject).to include(process1, process2, process3, restricted_process)
      end
    end

    context "with a normal participant" do
      let(:user) { create(:user, :confirmed, organization:) }

      it "returns all spaces including the restricted space" do
        expect(subject).to include(process1, process2, process3)
        expect(subject).not_to include(restricted_process)
      end
    end
  end
end
