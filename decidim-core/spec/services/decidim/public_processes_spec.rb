# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe PublicProcesses do
    let(:organization) { create(:organization) }
    let(:other_organization) { create(:organization) }
    let(:service) { described_class.new(organization) }

    before do
      @published_processes = create_list(:participatory_process, 2, :published, organization: organization)
      @unpublished_processes = create_list(:participatory_process, 2, :unpublished, organization: organization)
      @organization_groups = create_list(:participatory_process_group, 2, organization: organization)
      @other_groups = create_list(:participatory_process_group, 2, organization: other_organization)
    end

    describe "collection" do
      subject { service.collection }

      it { is_expected.to contain_exactly(*@published_processes, *@organization_groups) }
    end
  end
end
