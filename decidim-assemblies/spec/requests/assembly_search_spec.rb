# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Assembly search" do
  subject { response.body }

  let(:organization) { create(:organization) }
  let!(:assembly1) do
    create(
      :assembly,
      organization:
    )
  end
  let!(:assembly2) do
    create(
      :assembly,
      organization:
    )
  end

  let(:filter_params) { {} }
  let(:request_path) { decidim_assemblies.assemblies_path(locale: I18n.locale) }

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

  it_behaves_like "a participatory space search with taxonomies", :assembly
end
