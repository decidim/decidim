# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteFriends do
    let(:command) { described_class.new(form) }
    let(:user) { create(:user, :confirmed) }

    let(:email_1) { "my_email_1@example.org" }
    let(:email_2) { nil }
    let(:email_3) { nil }
    let(:email_4) { nil }
    let(:email_5) { nil }
    let(:email_6) { nil }
    let(:custom_message) { "Come to Decidim!" }

    let(:form) do
      InvitationsForm.from_params(
        email_1: email_1,
        email_2: email_2,
        email_3: email_3,
        email_4: email_4,
        email_5: email_5,
        email_6: email_6,
        custom_message: custom_message
      ).with_context(current_organization: user.organization, current_user: user)
    end

    context "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "doesn't update anything" do
        expect(InviteUser).not_to receive(:call)
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      it "invites the users" do
        expect(form).to receive(:clean_emails).and_call_original
        expect(InviteUser).to receive(:call).and_call_original
        expect { command.call }.to broadcast(:ok)

        invited_user = User.find_by(email: email_1, organization: user.organization)
        expect(invited_user.name).to eq "my_email_1"
        expect(invited_user.email).to eq email_1
        expect(invited_user.invited_by).to eq user
        expect(invited_user.admin).to eq false
        expect(invited_user.roles).to be_empty
      end
    end
  end
end
