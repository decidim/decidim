# frozen_string_literal: true

require "spec_helper"

describe "Admin reports user", type: :system do
  it_behaves_like "hideable resource during block" do
    let(:reportable) { content.author }

    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:dummy_component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:content) { create(:comment, commentable:) }
  end
end
