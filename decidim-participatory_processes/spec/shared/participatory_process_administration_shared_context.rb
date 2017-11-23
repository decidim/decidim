# frozen_string_literal: true

shared_context "when administrating a participatory process" do
  let(:organization) { create(:organization) }

  let!(:participatory_process) { create(:participatory_process, organization: organization) }

  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) { Decidim::Dev.asset(image1_filename) }
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) { Decidim::Dev.asset(image2_filename) }
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) { Decidim::Dev.asset(image3_filename) }
end
