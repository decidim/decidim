require "spec_helper"

module Decidim
  describe InviteUserAgain do
    command { described_class.new(user, "invite_admin") }
    context "when the user was invited" do
      let(:user) { build(:user).invite! }

      it "sends the invitation instructions"
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:valid)
    end

    context "when the user was not invited initially" do
      let(:user) { create(:user) }

      it "does not send an email"
      it "broadcasts invalid"
    end
  end
end
