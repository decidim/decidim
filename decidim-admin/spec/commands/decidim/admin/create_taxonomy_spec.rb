# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateTaxonomy do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:name) { attributes_for(:taxonomy)[:name] }
    let(:form) do
      double(
        invalid?: invalid,
        name:,
        organization:,
        current_user: user,
        parent_id:
      )
    end
    let(:invalid) { false }
    let(:parent_id) { nil }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      it "creates the taxonomy" do
        expect { subject.call }.to change(Decidim::Taxonomy, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the name" do
        subject.call
        expect(Decidim::Taxonomy.last.name).to eq(name)
      end

      it "sets the organization" do
        subject.call
        expect(Decidim::Taxonomy.last.organization).to eq(organization)
      end

      context "when parent_id is provided" do
        let!(:parent) { create(:taxonomy, organization:) }
        let!(:parent_id) { parent.id }

        it "sets the parent" do
          expect do
            subject.call
          end.to change(Decidim::Taxonomy, :count).by(1)

          created_taxonomy = Decidim::Taxonomy.find_by(parent_id: parent.id)

          expect(created_taxonomy.parent).to eq(parent)
          expect(created_taxonomy.id).not_to eq(parent.id)
          expect(created_taxonomy.name).to eq(name)
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::Taxonomy,
            form.current_user,
            hash_including(:name, :organization, :parent_id),
            hash_including(extra: hash_including(:parent_name))
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
