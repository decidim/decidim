# frozen_string_literal: true

require "spec_helper"

shared_examples_for "m-cell" do |model_name|
  context "with decorated title" do
    let(:cell_model) { send(model_name) }

    before do
      cell_model.update!(title: { en: "Model <strong>decorated title</strong>" })
    end

    it "renders the escaped title correctly" do
      expect(cell_html.to_s).to include("Model &lt;strong&gt;decorated title&lt;/strong&gt;")
    end
  end
end
