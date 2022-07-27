# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe InviteAdmin do
    let(:invited_user) { Decidim::User.find_by(email: "me@example.org") }
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
        current_user:
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

    it "tracks the change", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("invite", a_kind_of(Decidim::User), current_user, extra: { invited_user_role: form.role, invited_user_id: a_kind_of(Integer) })
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.extra["version"]).to be_nil
      expect(action_log.extra)
        .to include(
          "extra" => {
            "invited_user_role" => "admin",
            "invited_user_id" => invited_user.id
          }
        )
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
