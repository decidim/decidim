# frozen_string_literal: true

shared_examples "visit unpublished resource with a share token" do
  context "when no share_token is provided" do
    before do
      visit_resource_page
    end

    it "does not allow visiting resource" do
      expect(page).to have_content "You are not authorized"
      expect(page).to have_no_current_path(resource_path, ignore_query: true)
    end
  end

  context "when a share_token is provided" do
    let(:share_token) { create(:share_token, :with_token, token_for: resource) }
    let(:params) { { share_token: share_token.token } }

    before do
      uri = URI(resource_path)
      uri.query = URI.encode_www_form(params.to_a)
      visit uri
    end

    context "when a valid share_token is provided" do
      it "allows visiting the resource" do
        expect(page).to have_no_content "You are not authorized"
        expect(current_url).to include(params[:share_token])
        expect(page).to have_current_path(resource_path, ignore_query: true)

        # repeat visit without the token in the params to check for the session
        visit resource_path
        expect(page).to have_no_content "You are not authorized"
        expect(current_url).not_to include(params[:share_token])
        expect(page).to have_current_path(resource_path, ignore_query: true)
      end
    end

    context "when an invalid share_token is provided" do
      let(:share_token) { create(:share_token, :with_token, :expired, token_for: resource) }

      it "does not allow visiting resource" do
        expect(page).to have_content "You are not authorized"
        expect(page).to have_no_current_path(resource_path, ignore_query: true)
      end
    end

    context "when the token requires the user to be registered" do
      let(:share_token) { create(:share_token, :with_token, token_for: resource, registered_only: true) }

      it "does not allow visiting resource" do
        expect(page).to have_content "You are not authorized"
        expect(page).to have_no_current_path(resource_path, ignore_query: true)
      end

      context "when a user is logged" do
        let(:user) { create(:user, :confirmed, organization:) }

        it "allows visiting resource" do
          login_as user, scope: :user
          uri = URI(resource_path)
          uri.query = URI.encode_www_form(params.to_a)
          visit uri
          expect(page).to have_no_content "You are not authorized"
          expect(page).to have_current_path(resource_path, ignore_query: true)
        end
      end
    end
  end
end

shared_examples "preview component with a share_token" do
  let!(:component) { create(:component, manifest_name:, participatory_space:, published_at: nil) }
  let(:resource) { component }
  let(:resource_path) { main_component_path(component) }

  def visit_resource_page
    visit_component
  end

  it_behaves_like "visit unpublished resource with a share token"
end

shared_examples "preview participatory space with a share_token" do
  let(:resource) { participatory_space }

  before do
    switch_to_host(organization.host)
  end

  def visit_resource_page
    visit resource_path
  end

  it_behaves_like "visit unpublished resource with a share token"
end
