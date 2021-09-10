# frozen_string_literal: true

shared_context "with test bulletin board" do
  before do |test|
    unless test.metadata[:bulletin_board_reset]
      Decidim::Elections.bulletin_board.reset_test_database
      test.metadata[:bulletin_board_reset] = true
    end
  end

  include_context "when managing a component as an admin" do
    let(:admin_component_organization_traits) { [:secure_context] }
  end
end
