# frozen_string_literal: true

shared_context "with a two-factor organization" do
  let(:organization) { create(:organization, :with_two_factor_authentication_enabled) }
  let(:password) { "decidim123456789" }
  let(:user) { create(:user, :confirmed, organization:) }
end
