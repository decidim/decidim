# frozen_string_literal: true

shared_examples "follows" do
  include_context "with a feature"

  before do
    login_as user, scope: :user
  end

  context "when not following the followable" do
    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit resource_locator(followable).path
        expect do
          click_button "Follow"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end

  context "when the user is following the followable" do
    before do
      create(:follow, followable: followable, user: user)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit resource_locator(followable).path
        expect do
          click_button "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end
end
