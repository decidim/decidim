# frozen_string_literal: true

shared_examples "an enrollment issuing recovery codes" do
  it "broadcasts ok with a fresh set of recovery codes" do
    expect { subject.call }.to broadcast(:ok, all(be_a(String)).and(have_attributes(size: Decidim.two_factor_recovery_codes_count)))
  end

  context "when the user already has unused recovery codes" do
    before { Decidim::TwoFactor::RegenerateRecoveryCodes.call(user) }

    it "broadcasts ok without new codes" do
      expect { subject.call }.to broadcast(:ok, nil)
    end
  end
end

shared_context "with a two-factor request session" do
  include_context "with a two-factor organization"

  let(:headers) { { "HOST" => organization.host } }
  let(:routes) { Decidim::Core::Engine.routes.url_helpers }

  def sign_in_with_password
    post(routes.user_session_path(locale: "en"), params: { user: { email: user.email, password: } }, headers:)
  end
end

shared_examples "a two-factor page hidden without two-factor authentication" do
  let(:organization) { create(:organization) }

  it "redirects to the account" do
    get(path, headers:)

    expect(response).to redirect_to(routes.account_path(locale: "en"))
  end
end
