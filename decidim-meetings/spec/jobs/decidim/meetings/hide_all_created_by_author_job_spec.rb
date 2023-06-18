# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::HideAllCreatedByAuthorJob do
  subject { described_class }

  it_behaves_like "has hideable resource" do
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, :published, manifest_name: :meetings, participatory_space: participatory_process) }
    let!(:hideable) { create(:meeting, component:, author:) }
    let!(:not_hideable) { create(:meeting, component:) }
  end
end
