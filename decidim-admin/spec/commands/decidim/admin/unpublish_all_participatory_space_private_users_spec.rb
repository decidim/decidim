# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnpublishAllParticipatorySpacePrivateUsers do
    subject { described_class.new(privatable_to) }

    let!(:privatable_to) { create(:participatory_process) }
    let!(:user) { create(:user, email: "my_email@example.org", organization: privatable_to.organization) }
    let!(:private_user) { create(:participatory_space_private_user, :published, user:, privatable_to:, role: { en: "Member" }) }

    it "updates the published attribute" do
      subject.call

      expect(private_user.reload.published).to be(false)
    end
  end
end
