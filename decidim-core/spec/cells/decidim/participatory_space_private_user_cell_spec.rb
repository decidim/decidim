# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatorySpacePrivateUserCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController

  let(:my_cell) { cell("decidim/participatory_space_private_user", model) }
  let(:user) { create(:user, :confirmed) }
  let(:role) { { "en" => "responsible for community outreach" } }
  let(:member) { create(:participatory_space_private_user, user:, role:) }
  let(:model) { Decidim::ParticipatorySpacePrivateUserPresenter.new(member) }

  it "renders the member's name, nickname and role" do
    expect(subject).to have_text(user.name)
    expect(subject).to have_text(user.nickname)
    expect(subject).to have_text("responsible for community outreach")
  end

  it "does not apply a text transform to the role text" do
    expect(subject).to have_no_css(".capitalize")
  end
end
