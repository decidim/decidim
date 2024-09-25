# frozen_string_literal: true

shared_examples_for "has taxonomies" do
  describe "taxonomies" do
    context "when valid taxonomies are assigned" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization: subject.organization) }
      before do
        subject.taxonomies = [taxonomy]
      end

      it { is_expected.to be_valid }
    end

    context "when a root taxonomy is assigned" do
      let!(:taxonomy) { create(:taxonomy, organization: subject.organization) }

      it "is not valid" do
        expect { subject.taxonomies = [taxonomy] }.to raise_error(ActiveRecord::RecordInvalid).or change { subject.valid? }.to(false)
      end
    end

    context "when a taxonomy from another organization is assigned" do
      let(:taxonomy) { create(:taxonomy, :with_parent) }
      before do
        subject.taxonomies = [taxonomy]
      end

      it { is_expected.to be_invalid }
    end
  end

  describe "scopes" do
    let(:root_taxonomy) { create(:taxonomy, organization: subject.organization) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: subject.organization) }

    let(:another_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: subject.organization) }
    let!(:taxonomization) { create(:taxonomization, taxonomizable: subject, taxonomy:) }
    let!(:another_taxonomization) { create(:taxonomization, taxonomy: another_taxonomy) }

    describe ".with_taxonomy" do
      it "returns the taxonomizable" do
        expect(described_class.with_taxonomy(taxonomy.id)).to eq([subject])
        expect(described_class.with_taxonomy(root_taxonomy.id)).to eq([subject])
      end

      it "returns empty if not in the taxonomy" do
        expect(described_class.with_taxonomy(another_taxonomy.id)).to be_empty
      end
    end

    describe ".with_taxonomies" do
      it "returns the taxonomizable" do
        expect(described_class.with_taxonomies(taxonomy.id, another_taxonomization.id)).to eq([subject])
        expect(described_class.with_taxonomies(root_taxonomy.id, another_taxonomization.id)).to eq([subject])
      end

      it "returns empty if not in the taxonomy" do
        expect(described_class.with_taxonomies(another_taxonomy.id)).to be_empty
      end
    end

    describe ".with_any_taxonomies" do
      let!(:missing_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: subject.organization) }
      let(:second_root_taxonomy) { create(:taxonomy, organization: subject.organization) }
      let(:second_taxonomy) { create(:taxonomy, parent: second_root_taxonomy, organization: subject.organization) }
      let!(:second_taxonomization) { create(:taxonomization, taxonomizable: subject, taxonomy: second_taxonomy) }
      let(:third_root_taxonomy) { create(:taxonomy, organization: subject.organization) }
      let(:third_taxonomy) { create(:taxonomy, parent: third_root_taxonomy, organization: subject.organization) }
      let!(:third_taxonomization) { create(:taxonomization, taxonomizable: subject, taxonomy: third_taxonomy) }

      it "returns the taxonomizable matching all subsets" do
        subset1 = [root_taxonomy.id, [taxonomy.id, another_taxonomy.id]]
        subset2 = [second_root_taxonomy.id, [second_taxonomy.id]]
        subset3 = [third_root_taxonomy.id, [third_taxonomy.id]]
        expect(described_class.with_any_taxonomies(subset1, subset2, subset3)).to eq([subject])
      end

      it "returns empty if one subset is missing" do
        subset1 = [root_taxonomy.id, [missing_taxonomy.id]]
        subset2 = [second_root_taxonomy.id, [second_taxonomy.id]]
        subset3 = [third_root_taxonomy.id, [third_taxonomy.id]]
        expect(described_class.with_any_taxonomies(subset1, subset2, subset3)).to be_empty
      end

      it "returns the taxonomizable if all taxonomies are present in the missing subset" do
        subset1 = [root_taxonomy.id, [missing_taxonomy.id, "all"]]
        subset2 = [second_root_taxonomy.id, [second_taxonomy.id]]
        subset3 = [third_root_taxonomy.id, [third_taxonomy.id]]

        expect(described_class.with_any_taxonomies(subset1, subset2, subset3)).to eq([subject])
      end
    end
  end
end
