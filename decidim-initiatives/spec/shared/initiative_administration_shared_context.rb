# frozen_string_literal: true

shared_context "when admins initiative" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:author) { create(:user, :confirmed, organization:) }
  let(:other_initiatives_type) { create(:initiatives_type, organization:, signature_type: "any") }
  let!(:other_initiatives_type_scope) { create(:initiatives_type_scope, type: other_initiatives_type) }

  let(:initiative_type) { create(:initiatives_type, organization:) }
  let(:initiative_scope) { create(:initiatives_type_scope, type: initiative_type) }
  let!(:initiative) { create(:initiative, organization:, scoped_type: initiative_scope, author:) }

  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) { Decidim::Dev.asset(image1_filename) }
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) { Decidim::Dev.asset(image2_filename) }
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) { Decidim::Dev.asset(image3_filename) }
end
