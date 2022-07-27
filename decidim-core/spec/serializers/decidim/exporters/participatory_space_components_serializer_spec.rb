# frozen_string_literal: true

require "spec_helper"

module Decidim::Exporters
  describe ParticipatorySpaceComponentsSerializer do
    describe "#serialize" do
      subject do
        described_class.new(participatory_space)
      end

      let!(:component1) { create(:component) }
      let!(:participatory_space) { component1.participatory_space }
      let!(:component2) { create(:component, participatory_space:) }
      let(:components) do
        { component1.id => component1, component2.id => component2 }
      end
      let(:previous_conf) { {} }

      class DummySpecificDataSerializer < Decidim::Exporters::Serializer
        def serialize
          { specific: :data }
        end
      end

      before do
        manifest = component2.manifest
        previous_conf[:serializes_specific_data] = manifest.serializes_specific_data
        manifest.serializes_specific_data = true
        previous_conf[:specific_data_serializer_class_name] = manifest.specific_data_serializer_class_name
        manifest.specific_data_serializer_class_name = DummySpecificDataSerializer.name
      end

      after do
        manifest = component2.manifest
        manifest.serializes_specific_data = previous_conf[:serializes_specific_data]
        manifest.specific_data_serializer_class_name = previous_conf[:specific_data_serializer_class_name]
      end

      describe "with specific data" do
        let(:serialized) { subject.serialize }

        it "serializes space components and their specific data when exists" do
          expect(serialized.size).to eq(2)
          serialized.each do |serialized|
            serialized_component_attrs_should_be_as_expected(serialized)
            expect(serialized[:specific_data]).to eq(specific: :data) if serialized[:id] == component2.id
          end
        end

        def serialized_component_attrs_should_be_as_expected(serialized)
          component = components[serialized[:id]]
          expect(serialized[:manifest_name]).to eq(component.manifest_name)
          expect(serialized[:name]).to eq(component.name)
          expect(serialized[:participatory_space_id]).to eq(component.participatory_space_id)
          expect(serialized[:participatory_space_type]).to eq(component.participatory_space_type)
          expect(serialized[:global]).to eq(component[:settings][:global].as_json)
          expect(serialized[:weight]).to eq(component.weight)
          expect(serialized[:permissions]).to eq(component.permissions)
          expect(serialized[:published_at]).to be_within(1.second).of(component.published_at)
        end
      end
    end
  end
end
