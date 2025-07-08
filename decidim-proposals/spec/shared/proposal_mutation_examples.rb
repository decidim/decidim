# frozen_string_literal: true

shared_examples "manage proposal mutation examples" do
  context "when proposal answering disabled" do
    it "does not answer the proposal" do
      expect(response["answer"]).to be_nil
    end
  end

  context "when proposal answering enabled" do
    let!(:proposal_answering_enabled) { true }

    it "answers the proposal but not costs" do
      answer = response["answer"]
      expect(answer).to be_present
      expect(answer).to include(
        {
          "id" => model.id.to_s,
          "state" => state,
          "answer" => {
            "translation" => answer_content[:en]
          },
          "cost" => nil,
          "costReport" => nil,
          "executionPeriod" => nil,
          "answeredAt" => model.reload.answered_at.to_time.iso8601
        }
      )
    end

    context "with enabled answering with cost" do
      let!(:proposal_answers_with_costs?) { true }

      it "answers the proposal and adds the cost" do
        answer = response["answer"]

        expect(answer).to be_present
        expect(answer).to include(
          {
            "id" => model.id.to_s,
            "state" => state,
            "answer" => {
              "translation" => answer_content[:en]
            },
            "cost" => "€1,234.00",
            "costReport" => {
              "translation" => cost_report[:en]
            },
            "executionPeriod" => {
              "translation" => execution_period[:en]
            },
            "answeredAt" => model.reload.answered_at.to_time.iso8601
          }
        )
      end
    end
  end
end
