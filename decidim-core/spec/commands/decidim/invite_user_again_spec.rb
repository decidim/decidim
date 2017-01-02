require "spec_helper"

module Decidim
  describe InviteUserAgain do
    context "when the user was invited" do
      it "sends the invitation instructions"
      it "broadcasts ok"
    end

    context "when the user was not invited initially" do
      it "does not send an email"
      it "broadcasts invalid"
    end
  end
end
