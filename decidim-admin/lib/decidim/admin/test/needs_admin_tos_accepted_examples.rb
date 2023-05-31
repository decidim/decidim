# frozen_string_literal: true

shared_examples "needs admin TOS accepted" do
  context "when the user has not accepted the admin TOS" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "shows a message to accept the admin TOS" do
      expect(page).to have_content("Please take a moment to review the admin terms of service")
    end
  end
end
