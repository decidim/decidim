# frozen_string_literal: true

shared_examples "logable participant details" do
  it "returns the participant private details" do
    expect(response["participantDetails"]).to include("email" => participant.email)
    expect(response["participantDetails"]).to include("nickname" => participant.nickname)
    expect(response["participantDetails"]).to include("name" => participant.name)
  end

  it "logs the action in action log" do
    expect { response }.to change(Decidim::ActionLog, :count).by(1)
    action_log = Decidim::ActionLog.last
    expect(action_log.user).to eq(current_user)
    expect(action_log.resource).to eq(participant)
  end
end
