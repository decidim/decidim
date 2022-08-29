# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustees::ByParticipatorySpaceTrusteeIds do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:assembly) { create(:assembly) }
  let(:user) { create :user, :confirmed }

  let(:participatory_process_trustees) do
    create_list(:trustee, 5) do |trustee|
      trustee.trustees_participatory_spaces << build(
        :trustees_participatory_space,
        participatory_space: participatory_process
      )
    end
  end

  let(:assembly_trustees) do
    create_list(:trustee, 5) do |trustee|
      trustee.trustees_participatory_spaces << build(
        :trustees_participatory_space,
        participatory_space: assembly
      )
    end
  end

  it "returns trustees by trustee ids" do
    expect(described_class.new(assembly_trustees.pluck(:id))).to match_array assembly_trustees
    expect(described_class.new(assembly_trustees.pluck(:id))).not_to match_array participatory_process_trustees
  end
end
