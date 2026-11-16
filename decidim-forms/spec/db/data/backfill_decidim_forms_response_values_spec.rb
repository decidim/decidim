# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261013100100_backfill_decidim_forms_response_values"

describe BackfillDecidimFormsResponseValues do
  let(:migrator) { described_class.new.tap { |migration| migration.verbose = false } }

  let(:questionnaire) { create(:questionnaire) }
  let(:text_question) { create(:questionnaire_question, questionnaire:, question_type: "short_response") }
  let(:single_question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type: "single_option") }
  let(:multiple_question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type: "multiple_option") }
  let(:sorting_question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type: "sorting") }
  let(:matrix_single_question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type: "matrix_single") }
  let(:single_rows) { create_list(:question_matrix_row, 2, question: matrix_single_question) }
  let(:matrix_question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type: "matrix_multiple") }
  let(:matrix_rows) { create_list(:question_matrix_row, 2, question: matrix_question) }
  let(:files_question) { create(:questionnaire_question, questionnaire:, question_type: "files") }
  let(:title_question) { create(:questionnaire_question, questionnaire:, question_type: "title_and_description") }

  def legacy_response(question, **attributes)
    row = { decidim_questionnaire_id: questionnaire.id, decidim_question_id: question.id, session_token: "token", created_at: 1.day.ago, updated_at: 1.day.ago }.merge(attributes)
    Decidim::Forms::Response.insert_all([row]).first["id"] # rubocop:disable Rails/SkipsModelValidations
  end

  def legacy_choice(response_id, option, **attributes)
    row = { decidim_response_id: response_id, decidim_response_option_id: option.id, body: option.body["en"] }.merge(attributes)
    Decidim::Forms::ResponseChoice.insert_all([row]) # rubocop:disable Rails/SkipsModelValidations
  end

  def value_of(response_id)
    Decidim::Forms::Response.find(response_id).value
  end

  describe "#up" do
    it "stores text responses as strings" do
      id = legacy_response(text_question, body: "legacy")
      migrator.migrate(:up)
      expect(value_of(id)).to eq("legacy")
    end

    it "stores a single option with its free text and without a blank one" do
      with_text = legacy_response(single_question)
      legacy_choice(with_text, single_question.response_options[1], custom_body: "mine")
      without_text = legacy_response(single_question)
      legacy_choice(without_text, single_question.response_options[0], custom_body: "")

      migrator.migrate(:up)

      expect(value_of(with_text)).to eq("option" => single_question.response_options[1].id, "text" => "mine")
      expect(value_of(without_text)).to eq("option" => single_question.response_options[0].id)
    end

    it "stores a sorting in insertion order, not by position" do
      options = sorting_question.response_options
      id = legacy_response(sorting_question)
      legacy_choice(id, options[2], position: 1)
      legacy_choice(id, options[0], position: 0)
      legacy_choice(id, options[1], position: 2)

      migrator.migrate(:up)

      expect(value_of(id)).to eq([{ "option" => options[2].id }, { "option" => options[0].id }, { "option" => options[1].id }])
    end

    it "keys matrix multiple choices by row id" do
      options = matrix_question.response_options
      id = legacy_response(matrix_question)
      legacy_choice(id, options[0], decidim_question_matrix_row_id: matrix_rows[1].id)
      legacy_choice(id, options[1], decidim_question_matrix_row_id: matrix_rows[1].id, custom_body: "mine")
      legacy_choice(id, options[2], decidim_question_matrix_row_id: matrix_rows[0].id)

      migrator.migrate(:up)

      expect(value_of(id)).to eq(
        matrix_rows[0].id.to_s => [{ "option" => options[2].id }],
        matrix_rows[1].id.to_s => [{ "option" => options[0].id }, { "option" => options[1].id, "text" => "mine" }]
      )
    end

    it "keys matrix single choices by row id and keeps the oldest choice of a row" do
      options = matrix_single_question.response_options
      id = legacy_response(matrix_single_question)
      legacy_choice(id, options[0], decidim_question_matrix_row_id: single_rows[0].id)
      legacy_choice(id, options[1], decidim_question_matrix_row_id: single_rows[0].id)
      legacy_choice(id, options[2], decidim_question_matrix_row_id: single_rows[1].id, custom_body: "mine")

      migrator.migrate(:up)

      expect(value_of(id)).to eq(single_rows[0].id.to_s => { "option" => options[0].id }, single_rows[1].id.to_s => { "option" => options[2].id, "text" => "mine" })
    end

    it "leaves matrix choices without a row out of the value" do
      options = matrix_question.response_options
      id = legacy_response(matrix_question)
      legacy_choice(id, options[0], decidim_question_matrix_row_id: matrix_rows[0].id)
      legacy_choice(id, options[1])

      migrator.migrate(:up)

      expect(value_of(id)).to eq(matrix_rows[0].id.to_s => [{ "option" => options[0].id }])
    end

    it "stores the attachment ids of a files response" do
      id = legacy_response(files_question)
      response = Decidim::Forms::Response.find(id)
      second = create(:attachment, :with_pdf, attached_to: response, weight: 1)
      first = create(:attachment, :with_image, attached_to: response, weight: 0)

      migrator.migrate(:up)

      expect(value_of(id)).to eq([first.id, second.id])
    end

    it "keeps the label of a deleted option" do
      option = multiple_question.response_options[0]
      id = legacy_response(multiple_question)
      legacy_choice(id, option)
      option.delete

      migrator.migrate(:up)

      expect(value_of(id)).to eq([{ "option" => option.id, "label" => option.body["en"] }])
    end

    it "keeps the oldest choice of a single option response with several" do
      id = legacy_response(single_question)
      legacy_choice(id, single_question.response_options[2])
      legacy_choice(id, single_question.response_options[0])

      migrator.migrate(:up)

      expect(value_of(id)).to eq("option" => single_question.response_options[2].id)
    end

    it "leaves rows without a value untouched and counts them apart" do
      allow(migrator).to receive(:say)
      ids = [
        legacy_response(text_question, body: " \n"),
        legacy_response(multiple_question),
        legacy_response(files_question),
        legacy_response(title_question, body: "title-and-description"),
        legacy_response(single_question, body: "typed before the question type changed")
      ]

      expect { migrator.migrate(:up) }.not_to change(Decidim::Forms::Response, :count)
      expect(Decidim::Forms::Response.where(id: ids).pluck(:value)).to eq([nil, nil, nil, nil, nil])
      expect(migrator).to have_received(:say).with(/\A4 responses without an answer/)
      expect(migrator).to have_received(:say).with(/\A1 responses with data were left without a value/)
    end

    it "does nothing on a database without responses" do
      allow(migrator).to receive(:say)
      migrator.migrate(:up)
      expect(migrator).not_to have_received(:say)
    end

    it "fills only the rows without a value on a second run" do
      first = legacy_response(text_question, body: "legacy")
      migrator.migrate(:up)
      Decidim::Forms::Response.where(id: first).update_all(body: "changed") # rubocop:disable Rails/SkipsModelValidations
      second = legacy_response(text_question, body: "later")

      migrator.migrate(:up)

      expect(value_of(first)).to eq("legacy")
      expect(value_of(second)).to eq("later")
    end
  end

  describe "#down" do
    it "clears the values" do
      id = legacy_response(text_question, body: "legacy")
      migrator.migrate(:up)
      migrator.migrate(:down)
      expect(value_of(id)).to be_nil
    end
  end
end
