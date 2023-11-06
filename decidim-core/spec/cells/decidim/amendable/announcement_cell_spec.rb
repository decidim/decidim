# frozen_string_literal: true

require "spec_helper"

describe Decidim::Amendable::AnnouncementCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController

  let(:my_cell) { cell("decidim/amendable/announcement", emendation) }
  let!(:amendment) { create(:amendment, amendable:, emendation:) }
  let(:component) { create(:proposal_component) }
  let(:amendable) { create(:proposal, component:, title: %(Testing <a href="https://example.org">proposal</a>)) }
  let(:emendation) { create(:proposal, component:) }
  let!(:linked_proposal) do
    pr = create(:proposal, component:)
    emendation.link_resources(pr, "created_from_rejected_emendation")
    pr
  end
  let(:link_to_amendable) { Decidim::ResourceLocatorPresenter.new(amendable).path }

  it "renders the link to the amendable resource" do
    expect(subject.to_s).to include(
      %(<a href="#{link_to_amendable}"><strong>Testing proposal</strong></a>)
    )
  end
end
