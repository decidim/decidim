# frozen_string_literal: true

shared_context "with taxonomy importer model context" do
  let(:organization) { create(:organization) }
  let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
  let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
  let(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
  let!(:taxonomies) { [sub_taxonomy, another_taxonomy] }

  let!(:assembly) { create(:assembly, taxonomies:, title: { "en" => "Assembly" }, organization:) }
  let!(:participatory_process) { create(:participatory_process, title: { "en" => "Participatory Process" }, organization:) }
  let(:dummy_component) { create(:dummy_component, name: { "en" => "Dummy Component" }, participatory_space: assembly) }
  let!(:dummy_resource) { create(:dummy_resource, title: { "en" => "Dummy Resource" }, component: dummy_component, scope: nil) }

  let(:external_organization) { create(:organization, name: { "en" => "INVALID Organization" }) }
  let!(:external_assembly) { create(:assembly, title: { "en" => "INVALID Assembly" }, organization: external_organization) }
  let!(:external_participatory_process) { create(:participatory_process, title: { "en" => "INVALID Participatory Process" }, organization: external_organization) }
  let!(:external_component) { create(:dummy_component, name: { "en" => "INVALID Dummy Component" }, participatory_space: external_assembly) }
  let!(:external_resource) { create(:dummy_resource, title: { "en" => "INVALID Dummy Resource" }, component: external_component, scope: nil) }
end

shared_examples "a resource with title" do
  it "#name returns the title" do
    expect(subject.name).to eq(subject.title)
  end
end

shared_examples "a resource with taxonomies with no children" do
  it "#taxonomies returns the taxonomies" do
    expect(subject.taxonomies).to eq(
      name: subject.respond_to?(:title) ? subject.title : subject.name,
      origin: subject.to_global_id.to_s,
      children: {},
      resources: subject.resources
    )
  end
end

shared_examples "has resources" do
  it "#resources returns the resources" do
    expect(subject.resources).to eq({ resource.to_global_id.to_s => resource.title[I18n.locale.to_s] })
  end
end

shared_examples "a single root taxonomy" do
  let(:generated_taxonomies) { described_class.with(organization).to_taxonomies }

  it "returns the participatory Scopes" do
    expect(generated_taxonomies).to eq(
      root_taxonomy_name => described_class.to_h
    )
  end
end

shared_examples "can be converted to taxonomies" do
  let(:generated_taxonomies) { described_class.with(organization).to_taxonomies }

  it "taxonomies has a maximum of three levels" do
    generated_taxonomies.values.each do |item|
      item[:taxonomies].each do |taxonomy_name, taxonomy|
        expect(taxonomy[:name]).to be_a(Hash)
        expect(taxonomy[:children]).to be_a(Hash)
        expect(taxonomy[:resources]).to be_a(Hash)
        expect(taxonomy[:name][I18n.locale.to_s]).to eq(taxonomy_name)
        taxonomy[:children].each do |child_name, child|
          expect(child[:name]).to be_a(Hash)
          expect(child[:children]).to be_a(Hash)
          expect(child[:resources]).to be_a(Hash)
          expect(child[:name][I18n.locale.to_s]).to eq(child_name)
          child[:children].each do |grandchild_name, grandchild|
            expect(grandchild[:name]).to be_a(Hash)
            expect(grandchild[:children]).to be_a(Hash)
            expect(grandchild[:resources]).to be_a(Hash)
            expect(grandchild[:children]).to be_empty
            expect(grandchild[:name][I18n.locale.to_s]).to eq(grandchild_name)
          end
        end
      end
    end
  end
end

shared_examples "a single root taxonomy with no children" do
  it "returns the participatory process types as taxonomies" do
    expect(described_class.with(organization).to_h).to eq(
      {
        taxonomies: { subject.title[I18n.locale.to_s] => subject.taxonomies },
        filters: [
          {
            name: root_taxonomy_name,
            space_filter: true,
            space_manifest:,
            items: [[subject.title[I18n.locale.to_s]]],
            components: []
          }
        ]
      }
    )
  end
end
