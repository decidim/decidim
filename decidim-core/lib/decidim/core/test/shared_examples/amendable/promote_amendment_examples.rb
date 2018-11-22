# frozen_string_literal: true

shared_examples "promote amendment" do
  it "creates an amendable type resource" do
    expect { command.call }
      .to change(amendable.resource_manifest.model_class_name.constantize, :count)
      .by(1)
  end

  it "broadcasts ok" do
    expect { command.call }.to broadcast(:ok)
  end

  it "notifies the authors and followers of the amendable and emendation resources" do
    command.call

    expect(Decidim::EventsManager)
      .to receive(:publish)
  end
end
