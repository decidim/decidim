# frozen_string_literal: true

require "spec_helper"

describe Decidim::MemberCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController

  let(:my_cell) { cell("decidim/member", model) }
  let(:user) { create(:user, :confirmed) }
  let(:role) { { "en" => "responsible for community outreach" } }
  let(:member) { create(:member, user:, role:) }
  let(:model) { Decidim::ParticipatorySpace::MemberPresenter.new(member) }

  it "renders the member's name, nickname and role" do
    expect(subject).to have_content(user.name)
    expect(subject).to have_content(user.nickname)
    expect(subject).to have_content("responsible for community outreach")
  end

  it "does not apply a text transform to the role text" do
    expect(subject).to have_no_css(".capitalize")
  end
end
