# frozen_string_literal: true

shared_examples "validate amendment form" do
  let(:title) { "More sidewalks and less roads!" }
  let(:body) { "Everything would be better" }
  let(:emendation_fields) do
    {
      title: title,
      body: body
    }
  end

  context "when everything is OK" do
    it "broadcasts ok" do
      expect { create_command.call }.to broadcast(:ok)
      expect { accept_command.call }.to broadcast(:ok)
    end
  end

  context "when there's no title" do
    let(:title) { nil }

    it "broadcasts invalid" do
      expect { create_command.call }.to broadcast(:invalid)
      expect { accept_command.call }.to broadcast(:invalid)
    end
  end

  context "when the title is too long" do
    let(:body) { "A" * 200 }

    it "broadcasts invalid" do
      expect { create_command.call }.to broadcast(:invalid)
      expect { accept_command.call }.to broadcast(:invalid)
    end
  end

  context "when the body is not etiquette-compliant" do
    let(:body) { "A" }

    it "broadcasts invalid" do
      expect { create_command.call }.to broadcast(:invalid)
      expect { accept_command.call }.to broadcast(:invalid)
    end
  end

  context "when there's no body" do
    let(:body) { nil }

    it "broadcasts invalid" do
      expect { create_command.call }.to broadcast(:invalid)
      expect { accept_command.call }.to broadcast(:invalid)
    end
  end
end
