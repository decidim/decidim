# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe PublishAllParticipatorySpacePrivateUsers do
    subject { described_class.new(privatable_to, current_user) }

    let!(:privatable_to) { create(:participatory_process) }
    let!(:user) { create(:user, email: "my_email@example.org", organization: privatable_to.organization) }
    let!(:private_user) { create(:participatory_space_private_user, :unpublished, user:, privatable_to:, role:) }
    let(:role) { generate_localized_title(:role) }
    let(:current_user) { create(:user, email: "admin@example.org", organization: privatable_to.organization) }

    it "updates the published attribute" do
      subject.call

      expect(private_user.reload.published).to be(true)
    end

    it "creates an action log" do
      expect { subject.call }.to change(Decidim::ActionLog, :count).by(1)
    end
  end
end
