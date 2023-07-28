# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::HideAllCreatedByAuthorJob do
  subject { described_class }

  it_behaves_like "has hideable resource" do
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:debates_component, organization:) }
    let!(:hideable) { create(:debate, component:, author:) }
    let!(:not_hideable) { create(:debate, component:) }
  end
end
