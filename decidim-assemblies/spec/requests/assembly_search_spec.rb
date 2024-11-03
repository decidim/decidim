# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Assembly search" do
  subject { response.body }

  let(:organization) { create(:organization) }
  let!(:assembly1) do
    create(
      :assembly,
      organization:,
      assembly_type: create(:assemblies_type, organization:)
    )
  end
  let!(:assembly2) do
    create(
      :assembly,
      organization:,
      assembly_type: create(:assemblies_type, organization:)
    )
  end

  let(:filter_params) { {} }
  let(:request_path) { decidim_assemblies.assemblies_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all assemblies by default" do
    expect(subject).to include(decidim_escape_translated(assembly1.title))
    expect(subject).to include(decidim_escape_translated(assembly2.title))
  end

  context "when filtering by assembly type" do
    let(:filter_params) { { with_any_type: [assembly1.assembly_type.id] } }

    it "displays matching assemblies" do
      expect(subject).to include(decidim_escape_translated(assembly1.title))
      expect(subject).not_to include(decidim_escape_translated(assembly2.title))
    end
  end

  it_behaves_like "a participatory space search with taxonomies", :assembly
end
