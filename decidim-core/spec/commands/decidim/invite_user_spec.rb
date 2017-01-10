require "spec_helper"

module Decidim
  describe InviteUser do
    let(:organization) { create(:organization) }
    let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }
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
    let!(:command) { described_class.new(form) }
    let(:invited_user) { User.where(organization: organization).last }

    context "when a user with the given email already exists" do
      before do
        create(:user, email: form.email, organization: organization)
      end

      it "does not create another user" do
        expect do
          command.call
        end.to_not change { User.count }
      end
    end

    it "adds the roles for the user" do
      command.call

      expect(invited_user.role?("admin")).to be
    end

    context "when a user does not exist for the given email" do
      it "creates it" do
        expect do
          command.call
        end.to change { User.count }.by(1)

        expect(invited_user.email).to eq(form.email)
      end

      it "sends an invitation email with the given instructions" do
        command.call

        _, _, _, queued_user, _, queued_options = ActiveJob::Arguments.deserialize(ActiveJob::Base.queue_adapter.enqueued_jobs.first[:args])

        expect(queued_user).to eq(invited_user)
        expect(queued_options).to eq(invitation_instructions: "invite_admin")
      end
    end
  end
end
