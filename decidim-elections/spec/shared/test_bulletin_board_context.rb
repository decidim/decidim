# frozen_string_literal: true

shared_context "with test bulletin board" do
  before do |test|
    unless test.metadata[:bulletin_board_reset]
      Decidim::Elections.bulletin_board.reset_test_database
      test.metadata[:bulletin_board_reset] = true
    end
  end
end
