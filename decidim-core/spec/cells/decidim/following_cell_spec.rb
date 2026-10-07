# frozen_string_literal: true

require "spec_helper"

describe Decidim::FollowingCell, type: :cell do
  subject { cell_html }

  controller Decidim::ProfilesController

  let(:organization) { create(:organization) }
  let!(:model) { create(:user, :confirmed, organization:) }
  let(:followed) { create_list(:user, 30, :confirmed, organization:) }
  let!(:follows) { followed.map { |user| create(:follow, followable: user, user: model) } }
  let(:my_cell) { cell("decidim/following", model) }
  let(:cell_html) { my_cell.call }

  before do
    allow(my_cell).to receive(:url_for).and_return("/")
  end

  it "queries and initializes only the necessary amount of user records per page" do
    allow(Decidim::User).to receive(:allocate).and_call_original

    subject

    expect(Decidim::User).to have_received(:allocate).exactly(20).times
    expect(my_cell.public_followings.count).to eq(20)
  end
end
