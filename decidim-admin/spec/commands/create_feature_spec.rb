require "spec_helper"

module Decidim
  module Admin
    describe CreateFeature do
      let(:manifest) { Decidim.find_feature_manifest(:dummy) }
      let(:form) do
        instance_double(FeatureForm,
          name: {
            en: "My feature",
            ca: "La meva funcionalitat",
            es: "Mi funcionalidad"
          },
          invalid?: !valid,
          valid?: valid
        )
      end

      let(:participatory_process) { create(:participatory_process) }

      describe "when valid" do
        let(:valid) { true }

        it "broadcasts :ok and creates the feature" do
          expect {
            CreateFeature.call(manifest, form, participatory_process)
          }.to broadcast(:ok)

          expect(participatory_process.features).to_not be_empty
        end
      end

      describe "when in valid" do
        let(:valid) { false }

        it "creates the feature" do
          expect {
            CreateFeature.call(manifest, form, participatory_process)
          }.to broadcast(:invalid)

          expect(participatory_process.features).to be_empty
        end
      end
    end
  end
end
