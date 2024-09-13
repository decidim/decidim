# frozen_string_literal: true

# When using these shared examples, make sure there are no prior requests within
# the same group of examples where this is included. Otherwise you may end up
# in race conditions that cause these to fail as explained at:
# https://github.com/decidim/decidim/pull/6161
shared_examples "followable content for users" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when not following the followable" do
    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        find("#dropdown-trigger-resource-#{followable.id}").click

        expect do
          click_on "Follow"
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
        find("#dropdown-trigger-resource-#{followable.id}").click

        expect do
          click_on "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end
end

shared_examples "followable space content for users" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when not following the followable" do
    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path

        expect do
          click_on "Follow"
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
          click_on "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end
end

shared_examples "followable content for users with a component" do
  include_context "with a component"
  include_examples "followable content for users"

  context "when the user is following the followable's participatory space" do
    before do
      create(:follow, followable: followable.participatory_space, user:)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the followable" do
        visit followable_path
        find("#dropdown-trigger-resource-#{followable.id}").click

        expect do
          click_on "Follow"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end
end
