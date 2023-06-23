# frozen_string_literal: true

require "spec_helper"

describe Decidim::HighlightedParticipatoryProcessCell, type: :cell do
  controller Decidim::PagesController

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:processes) { create_list(:participatory_process, 5, organization:) }

  it "renders the highlighted participatory process" do
    html = cell("decidim/highlighted_participatory_process", processes.first).call
    expect(html).to have_content(translated(processes.first.title))
  end
end
