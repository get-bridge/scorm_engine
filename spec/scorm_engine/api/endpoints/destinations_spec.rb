RSpec.describe ScormEngine::Api::Endpoints::Destinations do
  client(:client) { scorm_engine_client }

  let(:destination_options) { {
    destination_id: "testing-golf-club",
    name: "Golf Club",
  } }

  before do
    against_real_scorm_engine do
      ensure_destination_exists(destination_options.merge(client: client))
    end
  end

  describe "#get_destinations" do
    let(:destinations) { client.get_destinations }

    it "is successful" do
      expect(destinations.success?).to eq true
    end

    describe "results" do
      it "is an enumerator of Destination models" do
        aggregate_failures do
          expect(destinations.results).to be_a Enumerator
          expect(destinations.results.first).to be_a ScormEngine::Models::Destination
        end
      end

      it "sucessfully creates the Destination attributes" do
        aggregate_failures do
          destination = destinations.results.detect { |c| c.id == destination_options[:destination_id] }
          expect(destination.name).to eq destination_options[:name]
        end
      end
    end

    describe ":since option" do
      it "works" do
        destinations = client.get_destinations(since: Time.parse("2000-01-1 00:00:00 UTC"))
        aggregate_failures do
          expect(destinations.success?).to eq true
          expect(destinations.results.to_a.size).to be >= 0
        end
      end

      it "fails when passed an invalid value" do
        destinations = client.get_destinations(since: "invalid")
        aggregate_failures do
          expect(destinations.success?).to eq false
          expect(destinations.status).to eq 400
          expect(destinations.results.to_a).to eq []
          expect(destinations.message).to match(/'invalid'/)
        end
      end
    end

    describe ":more option (pagination)" do
      before do
        against_real_scorm_engine do
          11.times do |idx|
            ensure_destination_exists(client: client, destination_id: "paginated-destination-#{idx}")
          end
        end
      end

      it "returns the :more key in the raw response" do
        expect(client.get_destinations.raw_response.body["more"]).to match(%r{(https?://)?.*&more=.+})
      end

      it "returns all the destinations" do
        expect(client.get_destinations.results.to_a.size).to be >= 11 # there may be other ones beyond those we just added
      end
    end
  end

  describe "#post_destination" do
    it "is successful" do
      client.delete_destination(destination_options)
      response = client.post_destination(destination_options)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "is successful even if the destination_id is not unique" do
      response = client.post_destination(destination_options)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end
  end

  describe "#get_destination" do
    let(:response) { client.get_destination(destination_id: destination_options[:destination_id]) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the destination attributes" do
        aggregate_failures do
          destination = response.result
          expect(destination.id).to eq destination_options[:destination_id]
          expect(destination.name).to eq destination_options[:name]
        end
      end
    end

    it "fails when id is invalid" do
      response = client.get_destination(destination_id: "nonexistent-destination")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/No destinations found with ID: nonexistent-destination/)
        expect(response.result).to eq nil
      end
    end
  end

  describe "#put_destination" do
    let(:response) { client.put_destination(destination_options.merge(name: "Golf & Country Club")) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the destination attributes" do
        response # trigger the put
        response = client.get_destination(destination_id: destination_options[:destination_id])
        destination = response.result
        expect(destination.name).to eq "Golf & Country Club"
      end
    end
  end

  describe "#delete_destination" do
    before do
      against_real_scorm_engine do
        ensure_destination_exists(client: client, destination_id: "destination-to-be-deleted")
      end
    end

    it "works" do
      response = client.delete_destination(destination_id: "destination-to-be-deleted")
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "raises ArgumentError when :destination_id is missing" do
      expect { client.delete_destination }.to raise_error(ArgumentError, /destination_id missing/)
    end

    it "returns success even when id is invalid" do
      response = client.delete_destination(destination_id: "nonexistent-destination")
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end
  end

  describe "#post_destination_dispatches_enabled" do
    it "works when true" do
      response = client.post_destination_dispatches_enabled(destination_id: destination_options[:destination_id], enabled: true)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "works when false" do
      response = client.post_destination_dispatches_enabled(destination_id: destination_options[:destination_id], enabled: false)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "fails when invalid" do
      response = client.post_destination_dispatches_enabled(destination_id: destination_options[:destination_id], enabled: "oops")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
      end
    end
  end

  describe "#post_destination_dispatches_registration_instancing" do
    it "works when true" do
      response = client.post_destination_dispatches_registration_instancing(destination_id: destination_options[:destination_id], enabled: true)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "works when false" do
      response = client.post_destination_dispatches_registration_instancing(destination_id: destination_options[:destination_id], enabled: false)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "fails when invalid" do
      response = client.post_destination_dispatches_registration_instancing(destination_id: destination_options[:destination_id], enabled: "oops")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 400
      end
    end
  end

  describe "#get_destination_dispatches_registration_count" do
    it "works" do
      response = client.get_destination_dispatches_registration_count(destination_id: destination_options[:destination_id])
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 200
        expect(response.result).to be >= 0
      end
    end

    it "fails when invalid" do
      response = client.get_destination_dispatches_registration_count(destination_id: "nonexistent-destination")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/No destinations found with ID: nonexistent-destination/)
      end
    end
  end
end
