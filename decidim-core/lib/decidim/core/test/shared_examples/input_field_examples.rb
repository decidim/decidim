# frozen_string_literal: true

shared_examples_for "field with maximum length" do |field|
  describe "character counter" do
    let(:message) { "#{::Faker::Lorem.paragraph}\n#{::Faker::Lorem.paragraph}" }
    let(:max_length) { Decidim.config.maximum_conversation_message_length }

    before do
      allow(Decidim.config).to receive(
        :maximum_conversation_message_length
      ).and_return(max_length)
    end

    it "shows character counter" do
      fill_in field, with: message
      expect(page).to have_content("#{max_length - message.length} characters left")
    end
  end
end
