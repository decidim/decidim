# frozen_string_literal: true

RSpec.shared_context "when a resource is ready for global search" do
  let!(:author) { create(:user, :admin) }
  let!(:organization) { author.organization }
  let!(:scope1) { create :scope, organization: organization }

  let(:test_locales) { [:ca, :en, :es] }
  let(:description_1) do
    Decidim::Faker::Localized.prefixed("Nulla TestCheck accumsan tincidunt description Ow!", test_locales)
  end
end
