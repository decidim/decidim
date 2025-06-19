# frozen_string_literal: true

shared_examples "manage proposal mutation examples" do
  it "changes proposals state" do
    expect(response["answer"]).to include("id" => model.id.to_s)
    expect(response["answer"]).to include("state" => state)
    answer = Decidim::Proposals::Proposal.find(model.id).answer
    expect(answer["en"]).to eq(answer_en)
    expect(answer["fi"]).to eq(answer_fi)
    expect(answer["sv"]).to eq(answer_sv)
  end

  describe "add cost" do
    let(:query) do
      %(
        {
          answer(
            state: "accepted"
            cost: #{cost}
            costReport: {
              en: "#{cost_report[:en]}",
              fi: "#{cost_report[:fi]}",
              sv: "#{cost_report[:sv]}"
            }
            executionPeriod: {
              en: "#{execution_period[:en]}",
              fi: "#{execution_period[:fi]}",
              sv: "#{execution_period[:sv]}"
            }
          )
          {
            id
            state
          }
        }
      )
    end
    let(:cost) { Faker::Number.between(from: 1, to: 100_000.0).round(2).to_f }
    let(:cost_report) do
      {
        en: Faker::Lorem.paragraph,
        fi: Faker::Lorem.paragraph,
        sv: Faker::Lorem.paragraph
      }
    end
    let(:execution_period) do
      {
        en: Faker::Lorem.paragraph,
        fi: Faker::Lorem.paragraph,
        sv: Faker::Lorem.paragraph
      }
    end

    it "changes proposal's cost" do
      expect(response["answer"]).to include("state" => "accepted")
      expect(response["answer"]).to include("id" => model.id.to_s)
      proposal = Decidim::Proposals::Proposal.find(model.id)
      expect(proposal.cost).to eq(cost)
      expect(proposal.cost_report["en"]).to eq(cost_report[:en])
      expect(proposal.cost_report["fi"]).to eq(cost_report[:fi])
      expect(proposal.cost_report["sv"]).to eq(cost_report[:sv])
      expect(proposal.execution_period["en"]).to eq(execution_period[:en])
      expect(proposal.execution_period["fi"]).to eq(execution_period[:fi])
      expect(proposal.execution_period["sv"]).to eq(execution_period[:sv])
    end
  end
end
