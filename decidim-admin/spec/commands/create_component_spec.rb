require "spec_helper"
require "decidim/dummy_component_manifest"

module Decidim
  module Admin
    describe CreateComponent do
      let(:participatory_process) { create :participatory_process }

      let(:form) do
        double(
          name: { en: "My component", es: "Mi componente",
                  ca: "El meu component" },
          component_type: "dummy",
          invalid?: !valid,
          valid?: valid
        )
      end

      let(:valid) { true }
      subject { described_class.new(form, participatory_process) }

      context "when the form is not valid" do
        let(:valid) { false }

        it "broadcasts invalid and doesn't create the component" do
          expect { subject.call }.to broadcast(:invalid)
          expect(participatory_process.components).to be_empty
        end
      end

      context "when everything is ok" do
        it "creates the component" do
          subject.call
          component = participatory_process.components.first

          expect(component.name["en"]).to eq("My component")
        end

        it "fires the hooks" do
          raise "PENDING"
        end
      end
    end
  end
end
