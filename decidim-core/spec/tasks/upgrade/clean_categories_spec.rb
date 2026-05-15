# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:categories", type: :task do
  let(:category) { create(:category) }
  let(:component) { create(:component, participatory_space: category.participatory_space) }

  context "when executing task" do
    it "does not throw an exception" do
      expect { task.execute }.not_to raise_exception
    end

    context "when there are no errors" do
      let!(:entries) { create_list(:dummy_resource, 8, category:, component:) }

      it "avoid removing entries" do
        expect { task.execute }.not_to change(Decidim::Categorization, :count)
      end

      context "when running without issues" do
        let!(:entries) { create_list(:dummy_resource, 8, category:, component:) }
        let(:invalid) { entries.sample(4) }
        let!(:invalid_entries) { invalid.collect(&:categorization).collect(&:id) }

        context "when missing categorization classes" do
          it "removes entries" do
            expect(Decidim::Categorization.count).to eq(8)

            Decidim::Dev::DummyResource.where(id: invalid).delete_all
            expect(Decidim::Categorization.where(id: invalid_entries).length).to eq(4)
            expect { task.execute }.to change(Decidim::Categorization, :count).by(-invalid_entries.size)
            expect(Decidim::Categorization.where(id: invalid_entries).length).to eq(0)
          end
        end
      end
    end

    context "when there are errors" do
      let!(:entries) { create_list(:dummy_resource, 8, category:, component:) }
      let!(:invalid_entries) { entries.collect(&:categorization).collect(&:id).sample(4) }

      context "when missing categorization classes" do
        it "removes entries" do
          expect(Decidim::Categorization.count).to eq(8)
          Decidim::Categorization.where(id: invalid_entries).update_all(categorizable_type: "Decidim::Dev::MissingResource") # rubocop:disable Rails/SkipsModelValidations

          expect(Decidim::Categorization.where(categorizable_type: "Decidim::Dev::MissingResource").count).to eq(4)
          expect { task.execute }.to change(Decidim::Categorization, :count).by(-invalid_entries.size)
          expect(Decidim::Categorization.where(id: invalid_entries).length).to eq(0)
        end
      end
    end
  end
end
