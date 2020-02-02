# frozen_string_literal: true

shared_examples_for "collection has input sort" do |collection, field|
  describe "ASC" do
    let(:query) { %[{ #{collection}(order: {#{field}: "ASC"}) { id } }] }

    it "returns expected order" do
      ids = response[collection].map { |item| item["id"] }
      replies_ids = models.sort_by(&field.underscore.to_sym).map(&:id).map(&:to_s)
      expect(ids).to eq(replies_ids)
      expect(ids).not_to eq(replies_ids.reverse)
    end
  end

  describe "DESC" do
    let(:query) { %[{ #{collection}(order: {#{field}: "DESC"}) { id } }] }

    it "returns reversed order" do
      ids = response[collection].map { |item| item["id"] }
      replies_ids = models.sort_by(&field.underscore.to_sym).map(&:id).map(&:to_s)
      expect(ids).not_to eq(replies_ids)
      expect(ids).to eq(replies_ids.reverse)
    end
  end
end

shared_examples_for "collection has i18n input sort" do |collection, field|
  context "when locale is not specified" do
    describe "ASC" do
      let(:query) { %[{ #{collection}(order: { #{field}: "ASC" }) { id } }] }

      it "returns alphabetical order" do
        response_ids = response[collection].map { |item| item["id"].to_i }
        ids = models.sort_by { |item| item.public_send(field.to_sym)[current_organization.default_locale] }.map { |item| item.id.to_i }
        expect(response_ids).to eq(ids)
        expect(response_ids).not_to eq(ids.reverse)
      end
    end

    describe "DESC" do
      let(:query) { %[{ #{collection}(order: { #{field}: "DESC" }) { id } }] }

      it "returns revered alphabetical order" do
        response_ids = response[collection].map { |item| item["id"].to_i }
        ids = models.sort_by { |item| item.public_send(field.to_sym)[current_organization.default_locale] }.map { |item| item.id.to_i }
        expect(response_ids).not_to eq(ids)
        expect(response_ids).to eq(ids.reverse)
      end
    end
  end

  context "when locale is specified" do
    describe "ASC" do
      let(:query) { %[{ #{collection}(order: { #{field}: "ASC", locale: "ca" }) { id } }] }

      it "returns alphabetical order" do
        response_ids = response[collection].map { |item| item["id"].to_i }
        ids = models.sort_by { |item| item.public_send(field.to_sym)["ca"] }.map { |item| item.id.to_i }
        expect(response_ids).to eq(ids)
        expect(response_ids).not_to eq(ids.reverse)
      end
    end

    describe "DESC" do
      let(:query) { %[{ #{collection}(order: { #{field}: "DESC", locale: "ca" }) { id } }] }

      it "returns revered alphabetical order" do
        response_ids = response[collection].map { |item| item["id"].to_i }
        ids = models.sort_by { |item| item.public_send(field.to_sym)["ca"] }.map { |item| item.id.to_i }
        expect(response_ids).not_to eq(ids)
        expect(response_ids).to eq(ids.reverse)
      end
    end

    context "when locale does not exist in the organization" do
      let(:query) { %[{ #{collection}(order: { #{field}: "DESC", locale: "de" }) { id } }] }

      it "returns all the component ordered" do
        expect { response }.to raise_exception(Exception)
      end
    end
  end
end

shared_examples_for "connection has input sort" do |connection, field|
  describe "ASC" do
    let(:query) { %[{ #{connection}(order: {#{field}: "ASC"}) { edges { node { id } } } }] }

    it "returns expected order" do
      ids = response[connection]["edges"].map { |edge| edge["node"]["id"] }
      replies_ids = models.sort_by(&field.underscore.to_sym).map(&:id).map(&:to_s)
      expect(ids).to eq(replies_ids)
    end
  end

  describe "DESC" do
    let(:query) { %[{ #{connection}(order: {#{field}: "DESC"}) { edges { node { id } } } }] }

    it "returns reversed order" do
      ids = response[connection]["edges"].map { |edge| edge["node"]["id"] }
      replies_ids = models.sort_by(&field.underscore.to_sym).map(&:id).map(&:to_s)
      expect(ids).to eq(replies_ids.reverse)
    end
  end
end
