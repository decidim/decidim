# frozen_string_literal: true

RSpec.shared_context "when a resource is ready for global search" do
  let!(:organization) { create(:organization) }
  let!(:author) { create(:user, :admin, organization: organization) }
  let!(:scope1) { create :scope, organization: organization }

  let(:test_locales) { [:ca, :en, :es] }
  let(:description_1) do
    Decidim::Faker::Localized.prefixed("Poemes als terrats de l'Empordà, Ow!", test_locales)
  end
end
