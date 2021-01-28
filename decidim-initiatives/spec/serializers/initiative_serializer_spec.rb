# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe InitiativeSerializer do
    subject { described_class.new(initiative) }

    let(:initiative) { create(:initiative, :with_area) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: initiative.id)
      end

      it "includes the title" do
        expect(serialized).to include(title: initiative.title)
      end

      it "includes the description" do
        expect(serialized).to include(description: initiative.description)
      end

      it "includes the state" do
        expect(serialized).to include(state: initiative.state)
      end

      it "includes the created_at timestamp" do
        expect(serialized).to include(created_at: initiative.created_at)
      end

      it "includes the published_at timestamp" do
        expect(serialized).to include(published_at: initiative.published_at)
      end

      it "includes the signature_end_date" do
        expect(serialized).to include(signature_end_date: initiative.signature_end_date)
      end

      it "includes the signature_type" do
        expect(serialized).to include(signature_type: initiative.signature_type)
      end

      it "includes the number of signatures (supports)" do
        expect(serialized).to include(signatures: initiative.supports_count)
      end

      it "includes the scope name" do
        expect(serialized[:scope]).to include(name: initiative.scope.name)
      end

      it "includes the type title" do
        expect(serialized[:type]).to include(title: initiative.type.title)
      end

      it "includes the authors' ids" do
        expect(serialized[:authors]).to include(id: initiative.author_users.map(&:id))
      end

      it "includes the authors' names" do
        expect(serialized[:authors]).to include(name: initiative.author_users.map(&:name))
      end

      it "includes the area name" do
        expect(serialized[:area]).to include(name: initiative.area.name)
      end
    end
  end
end
