# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Assembly search", type: :request do
  subject { response.body }

  let(:organization) { create(:organization) }
  let!(:assembly1) do
    create(
      :assembly,
      organization:,
      assembly_type: create(:assemblies_type, organization:),
      area: create(:area, organization:),
      scope: create(:scope, organization:)
    )
  end
  let!(:assembly2) do
    create(
      :assembly,
      organization:,
      assembly_type: create(:assemblies_type, organization:),
      area: create(:area, organization:),
      scope: create(:scope, organization:)
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
    expect(subject).to include(translated(assembly1.title))
    expect(subject).to include(translated(assembly2.title))
  end

  context "when filtering by assembly type" do
    let(:filter_params) { { type_id_eq: assembly1.assembly_type.id } }

    it "displays matching assemblies" do
      expect(subject).to include(translated(assembly1.title))
      expect(subject).not_to include(translated(assembly2.title))
    end
  end

  context "when filtering by area" do
    let(:filter_params) { { with_area: assembly1.area.id } }

    it "displays matching assemblies" do
      expect(subject).to include(translated(assembly1.title))
      expect(subject).not_to include(translated(assembly2.title))
    end
  end

  context "when filtering by scope" do
    let(:filter_params) { { with_scope: assembly1.scope.id } }

    it "displays matching assemblies" do
      expect(subject).to include(translated(assembly1.title))
      expect(subject).not_to include(translated(assembly2.title))
    end
  end
end
