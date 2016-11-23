require "spec_helper"

module Decidim
  module Admin
    describe CreateComponent do
      let(:form) do
        double(
          name: { en: "My component", es: "Mi componente",
                  ca: "El meu component" },
          step_id: step.id,
          invalid?: !valid,
          valid?: valid
        )
      end

      let!(:feature) { create(:feature) }
      let!(:participatory_process) { feature.participatory_process }
      let!(:step) { create(:participatory_process_step, participatory_process: participatory_process) }

      let(:manifest) { feature.manifest.components.first }

      before(:each) { manifest.reset_hooks! }
      after(:each) { manifest.reset_hooks! }

      let(:valid) { true }
      subject { described_class.new(manifest, form, feature) }

      context "when the form is not valid" do
        let(:valid) { false }

        it "broadcasts invalid and doesn't create the component" do
          expect { subject.call }.to broadcast(:invalid)
          expect(feature.components).to be_empty
        end
      end

      context "when everything is ok" do
        it "creates the component" do
          subject.call
          component = feature.components.first

          expect(component.name["en"]).to eq("My component")
        end

        it "fires the hooks" do
          results = {}

          manifest.on(:create) do |component|
            results[:component] = component
          end

          subject.call

          component = results[:component]
          expect(component.name["en"]).to eq("My component")
          expect(component).to be_persisted
        end
      end
    end
  end
end
