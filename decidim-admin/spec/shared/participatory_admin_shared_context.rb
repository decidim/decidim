# frozen_string_literal: true

RSpec.shared_context "participatory process admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:process_admin) { create :user, :process_admin, :confirmed, organization: organization, participatory_process: participatory_process }

  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) { Decidim::Dev.asset(image1_filename) }
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) { Decidim::Dev.asset(image2_filename) }
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) { Decidim::Dev.asset(image3_filename) }
end
