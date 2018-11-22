# frozen_string_literal: true

shared_examples "create amendment" do
  it "creates an amendment and the emendation" do
    expect { command.call }
    .to change(Decidim::Amendment, :count)
    .by(1)
    .and change(amendable.resource_manifest.model_class_name.constantize, :count)
    .by(1)
  end

  it "broadcasts ok" do
    expect { command.call }.to broadcast(:ok)
  end

  it "notifies the authors and followers of the amendable resource" do
    command.call

    expect(Decidim::EventsManager)
    .to receive(:publish)
  end
end
