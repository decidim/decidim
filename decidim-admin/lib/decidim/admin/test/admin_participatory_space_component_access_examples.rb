# frozen_string_literal: true

shared_examples "accessing the component in a participatory space" do
  context "when the user is a visitor" do
    let(:user) { nil }

    it "shows the unauthenticated message" do
      expect(page).to have_text "You need to log in or create an account before continuing."
    end
  end

  context "when the user is a normal user" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:unauthorized_path) { "/" }

    before do
      login_as user, scope: :user
    end

    it_behaves_like "a 404 page" do
      let(:target_path) { manage_component_path(component) }
    end
  end

  context "when the user is a process admin" do
    let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

    before do
      login_as user, scope: :user
    end

    it "access the index page" do
      expect(page).to have_text(title)
    end
  end
end
