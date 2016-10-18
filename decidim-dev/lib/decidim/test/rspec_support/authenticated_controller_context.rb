# frozen_string_literal: true
RSpec.shared_context "authenticated user" do
  let(:user) { create(:user, :confirmed) }

  before do
    @request.env["decidim.current_organization"] = user.organization
    sign_in user, scope: :user
  end
end
