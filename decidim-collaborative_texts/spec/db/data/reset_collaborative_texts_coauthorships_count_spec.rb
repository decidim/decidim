# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261109135715_reset_collaborative_texts_coauthorships_count"

describe ResetCollaborativeTextsCoauthorshipsCount do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:component) { create(:collaborative_text_component) }
  let(:document) { create(:collaborative_text_document, :with_body, component:) }
  let(:contributor) { create(:user, :confirmed, organization: component.organization) }

  before do
    document.add_coauthor(contributor)
    # rubocop:disable-next Rails/SkipsModelValidations
    document.update_columns(coauthorships_count: 0, suggestions_count: 7)
  end

  it "resets the coauthorships counter" do
    expect { migrator.up }.to change { document.reload.coauthorships_count }.from(0).to(2)
  end

  it "does not change the other counters" do
    migrator.up

    expect(document.reload.suggestions_count).to eq(7)
  end
end
