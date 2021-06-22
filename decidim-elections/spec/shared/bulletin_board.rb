# frozen_string_literal: true

shared_context "with test bulletin board" do
  before do
    Decidim::Elections.bulletin_board.reset_test_database
  end
end
