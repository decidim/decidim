# frozen_string_literal: true

shared_examples "follows" do
  include_context "with a component"

  before do
    login_as user, scope: :user
  end

  context "when not following the followable" do
    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        expect do
          click_button "Follow"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end

  context "when the user is following the followable" do
    before do
      create(:follow, followable:, user:)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        expect do
          click_button "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end

  context "when the user is following the followable's participatory space" do
    before do
      create(:follow, followable: followable.participatory_space, user:)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        expect do
          click_button "Following #{translated(followable.participatory_space.title)}"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end
end
