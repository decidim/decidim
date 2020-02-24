# frozen_string_literal: true

require "spec_helper"

describe "Invitation", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { ::Decidim::User.invite!(name: generate(:name), email: generate(:email), organization: organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when accepting and invitation" do
    describe "if the user has already registered" do
      before do
        form = Decidim::RegistrationForm.new(
          name: generate(:name),
          email: user.email,
          nickname: generate(:nickname),
          password: "decidim102030",
          password_confirmation: "decidim102030",
          tos_agreement: true,
          newsletter: false,
          email_on_notification: true,
          accepted_tos_version: organization.tos_version
        ).with_context(current_organization: organization)
        Decidim::CreateRegistration.call(form) do
          on(:invalid) do
            raise "Should have not failed"
          end
        end
        invitation_token = user.raw_invitation_token
        visit decidim.accept_user_invitation_path(invitation_token: invitation_token)
      end

      it "redirects to the root path" do
        expect(page).to have_content("You had already registered, login with email #{user.email}")
      end
    end
  end
end
