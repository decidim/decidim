# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::DestroyAssembliesType, versioning: true do
    subject { described_class.new(assembly_type) }

    let(:assembly_type) { create :assemblies_type }

    context "when everything is ok" do
      it "destroys the assembly member" do
        subject.call
        expect { assembly_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
