# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::HideAllCreatedByAuthorJob do
  subject { described_class }

  it_behaves_like "has hideable resource" do
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let!(:hideable) { create(:comment, commentable:, author:) }
    let!(:not_hideable) { create(:comment, commentable:) }
  end
end
