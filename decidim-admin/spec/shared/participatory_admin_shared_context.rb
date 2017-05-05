# frozen_string_literal: true
RSpec.shared_context "participatory process admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:process_admin) { create :user, :confirmed, organization: organization }
  let!(:user_role) { create :participatory_process_user_role, user: process_admin, participatory_process: participatory_process }
  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image1_filename))
  end
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image2_filename))
  end
  let(:image3_filename) { "city3.jpeg" }
  let(:image3_path) do
    File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image3_filename))
  end
end
