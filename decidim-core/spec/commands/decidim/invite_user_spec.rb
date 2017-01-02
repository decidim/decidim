require "spec_helper"

module Decidim
  describe InviteUser do
    let(:organization) { create(:organization) }
    let(:admin) { create(:user, :confirmed, :admin, organization: organization) }
    let(:form) do
      Decidim::InviteAdminForm.from_params(
        name: "Old man",
        email: "oldman@email.com",
        organization: organization,
        roles: %w(admin),
        invited_by: admin,
        invitation_instructions: "invite_admin"
      )
    end

    context "when a user with the given email already exists" do
      it "does not create another user"
    end

    it "adds the roles for the user"

    context "when a user does not exist for the given email" do
      it "creates it"
      it "sends an invitation email with the given instructions"
    end
  end
end
