# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::ParticipatorySpace
  describe UnpublishAllMembers do
    subject { described_class.new(participatory_space, current_user) }

    let!(:participatory_space) { create(:participatory_process) }
    let!(:user) { create(:user, email: "my_email@example.org", organization: participatory_space.organization) }
    let!(:member) { create(:member, :published, user:, participatory_space:, role:) }
    let(:role) { generate_localized_title(:role) }
    let(:current_user) { create(:user, email: "admin@example.org", organization: participatory_space.organization) }

    it "updates the published attribute" do
      subject.call

      expect(member.reload.published).to be(false)
    end

    it "creates an action log" do
      expect { subject.call }.to change(Decidim::ActionLog, :count).by(1)
    end
  end
end
