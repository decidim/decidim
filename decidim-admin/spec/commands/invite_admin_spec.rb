# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe InviteAdmin do
    let(:invited_user) { Decidim::User.where(email: "me@example.org").first }
    let(:current_user) { create(:user, :admin) }
    let(:command) { described_class.new(form) }
    let(:invalid?) { false }
    let(:form) do
      double(
        invalid?: invalid?,
        role: :admin,
        email: "me@example.org",
        name: "Foo Bar",
        invited_by: current_user,
        invitation_instructions: "invite_admin",
        organization: current_user.organization,
        current_user: current_user
      )
    end

    it "invites the user" do
      expect(Decidim::InviteUser).to receive(:call).with(form).and_call_original
      command.call
    end

    it "sets the user nickname" do
      command.call
      expect(invited_user.nickname).to be_present
    end

    it "broadcasts ok" do
      expect do
        command.call
      end.to broadcast(:ok)
    end

    it "tracks the change" do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("invite", a_kind_of(Decidim::User), current_user, extra: { invited_user_role: form.role, invited_user_id: a_kind_of(Integer) })

      command.call
    end

    context "when the form is not valid" do
      let(:invalid?) { true }

      it "broadcasts invalid" do
        expect do
          command.call
        end.to broadcast(:invalid)
      end
    end
  end
end
