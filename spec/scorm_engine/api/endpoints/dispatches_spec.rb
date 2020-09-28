require "zip"

RSpec.describe ScormEngine::Api::Endpoints::Dispatches do
  let(:subject) { scorm_engine_client }

  let(:course_options) { {
    course_id: "testing-golf-explained"
  } }

  let(:destination_options) { {
    destination_id: "testing-golf-club",
    name: "Golf Club",
  } }

  let(:dispatch_options) { {
    destination_id: destination_options[:destination_id],
    course_id: course_options[:course_id],
    dispatch_id: "testing-dispatch-id-2",
    allow_new_registrations: false,
    instanced: false,
    registration_cap: 123,
    expiration_date: "2018-01-01",
  } }

  before do
    against_real_scorm_engine do
      ensure_course_exists(course_options.merge(client: subject))
      ensure_destination_exists(destination_options.merge(client: subject))
      ensure_dispatch_exists(dispatch_options.merge(client: subject))
    end
  end

  describe "#get_dispatches" do
    let(:dispatches) { subject.get_dispatches }

    it "is successful" do
      expect(dispatches.success?).to eq true
    end

    describe "results" do
      it "is an enumerator of dispatch models" do
        expect(dispatches.results).to be_a Enumerator
        expect(dispatches.results.first).to be_a ScormEngine::Models::Dispatch
      end

      it "sucessfully creates the dispatch attributes" do
        dispatch = dispatches.results.detect { |c| c.id == dispatch_options[:dispatch_id] }
        aggregate_failures do
          expect(dispatch.destination_id).to eq dispatch_options[:destination_id]
          expect(dispatch.course_id).to eq dispatch_options[:course_id]
          expect(dispatch.registration_cap).to be_a Integer
          expect(dispatch.registration_count).to be_a Integer
          expect(dispatch.enabled).to eq true
        end
      end
    end

    describe ":since option" do
      it "works" do
        dispatches = subject.get_dispatches(since: Time.parse("2000-01-1 00:00:00 UTC"))
        aggregate_failures do
          expect(dispatches.success?).to eq true
          expect(dispatches.results.to_a.size).to be >= 0
        end
      end

      it "fails when passed an invalid value" do
        dispatches = subject.get_dispatches(since: "invalid")
        aggregate_failures do
          expect(dispatches.success?).to eq false
          expect(dispatches.status).to eq 400
          expect(dispatches.results.to_a).to eq []
          expect(dispatches.message).to match(/'invalid' is either not a timestamp or seems to be not formatted according to ISO 8601/)
        end
      end
    end

    describe ":more option (pagination)" do
      before do
        against_real_scorm_engine do
          11.times do |idx|
            ensure_dispatch_exists(dispatch_options.merge(client: subject, dispatch_id: "paginated-dispatch-#{idx}"))
          end
        end
      end

      it "returns the :more key in the raw response" do
        expect(subject.get_dispatches.raw_response.body["more"]).to match(%r{(https?://)?.*&more=.+})
      end

      it "returns all the dispatches" do
        expect(subject.get_dispatches.results.to_a.size).to be >= 11 # there may be other ones beyond those we just added
      end
    end
  end

  describe "#post_dispatch" do
    it "is successful" do
      subject.delete_dispatch(dispatch_options)
      response = subject.post_dispatch(dispatch_options)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end
    end

    it "raises ArgumentError when :expiration_date is invalid string" do
      expect {
        subject.post_dispatch(dispatch_options.merge(expiration_date: "not-a-parsable-date"))
      }.to raise_error(ArgumentError, /Invalid option expiration_date/)
    end

    it "updates if same dispatch_id" do
      response = subject.get_dispatch(dispatch_id: dispatch_options[:dispatch_id])
      expect(response.result.expiration_date.to_date).to eq Date.new(2018, 1, 1)

      response = subject.post_dispatch(dispatch_options.merge(expiration_date: Date.new(2030, 1, 1)))
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 204
      end

      response = subject.get_dispatch(dispatch_id: dispatch_options[:dispatch_id])
      expect(response.result.expiration_date).to be_a Time
    end
  end

  describe "#get_dispatch" do
    let(:response) { subject.get_dispatch(dispatch_id: dispatch_options[:dispatch_id]) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the dispatch attributes" do
        dispatch = response.result
        aggregate_failures do
          expect(dispatch.id).to eq dispatch_options[:dispatch_id]
          expect(dispatch.destination_id).to eq dispatch_options[:destination_id]
          expect(dispatch.course_id).to eq dispatch_options[:course_id]
          expect(dispatch.registration_cap).to be_a Integer
          expect(dispatch.registration_count).to be_a Integer
          expect(dispatch.enabled).to eq true
        end
      end
    end

    it "fails when id is invalid" do
      response = subject.get_dispatch(dispatch_id: "nonexistent-dispatch")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/No dispatches found with ID: nonexistent-dispatch/)
        expect(response.result).to eq nil
      end
    end
  end

  describe "#put_dispatch" do
    let(:response) { subject.put_dispatch(dispatch_options) }

    %i[
      dispatch_id destination_id course_id allow_new_registrations
      instanced registration_cap expiration_date
    ].each do |arg|
      it "raises ArgumentError when :#{arg} is missing" do
        dispatch_options.delete(arg)
        expect { subject.put_dispatch(dispatch_options) }.to raise_error(ArgumentError, /#{arg} missing/)
      end
    end

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the dispatch attributes" do
        response # trigger the put
        response = subject.get_dispatch(dispatch_id: dispatch_options[:dispatch_id])
        dispatch = response.result
        aggregate_failures do
          expect(dispatch.allow_new_registrations).to eq false
          expect(dispatch.instanced).to eq false
          expect(dispatch.registration_cap).to eq 123
          expect(dispatch.expiration_date.to_date).to eq Date.new(2018, 1, 1)
        end
      end
    end
  end

  describe "#delete_dispatch" do
    before do
      against_real_scorm_engine do
        ensure_dispatch_exists(dispatch_options.merge(client: subject, dispatch_id: "dispatch-to-be-deleted"))
      end
    end

    it "works" do
      response = subject.delete_dispatch(dispatch_id: "dispatch-to-be-deleted")
      expect(response.success?).to eq true
      expect(response.status).to eq 204
    end

    it "raises ArgumentError when :dispatch_id is missing" do
      expect { subject.delete_dispatch }.to raise_error(ArgumentError, /dispatch_id missing/)
    end

    it "returns success even when id is invalid" do
      response = subject.delete_dispatch(dispatch_id: "nonexistent-dispatch")
      expect(response.success?).to eq true
      expect(response.status).to eq 204
    end
  end

  describe "#get_dispatch_enabled" do
    it "is true when enabled" do
      subject.put_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id], enabled: true)
      response = subject.get_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id])
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 200
        expect(response.result).to eq true
      end
    end

    it "is false when disabled" do
      subject.put_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id], enabled: false)
      response = subject.get_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id])
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 200
        expect(response.result).to eq false
      end
    end
  end

  describe "#put_dispatch_enabled" do
    it "works when true" do
      response = subject.put_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id], enabled: true)
      expect(response.success?).to eq true
      expect(response.status).to eq 204
    end

    it "works when false" do
      response = subject.put_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id], enabled: false)
      expect(response.success?).to eq true
      expect(response.status).to eq 204
    end

    it "fails when invalid" do
      response = subject.put_dispatch_enabled(dispatch_id: dispatch_options[:dispatch_id], enabled: "oops")
      expect(response.success?).to eq false
      expect(response.status).to eq 400
    end
  end

  describe "#get_dispatch_zip" do
    it "works" do
      response = subject.get_dispatch_zip(dispatch_id: dispatch_options[:dispatch_id])
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.status).to eq 200
        expect(response.result.dispatch_id).to eq dispatch_options[:dispatch_id]
        expect(response.result.type).to eq "SCORM12"
        expect(response.result.filename).to end_with("golf_club_dispatch_testing-dispatch-id-2.zip")

        zip_contents = Zip::File.open_buffer(StringIO.new(response.result.body)).each_entry.map(&:name)
        expect(zip_contents).to include("blank.html", "configuration.js", "dispatch.html", "goodbye.html") # sampling
      end
    end

    it "works when type is SCORM12" do
      response = subject.get_dispatch_zip(dispatch_id: dispatch_options[:dispatch_id], type: "scorm12".freeze)
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.result.type).to eq "SCORM12"

        zip_contents = Zip::File.open_buffer(StringIO.new(response.result.body)).each_entry.map(&:name)
        expect(zip_contents).to include("blank.html", "configuration.js", "dispatch.html", "goodbye.html") # sampling
      end
    end

    it "works when type is SCORM2004-3RD" do
      response = subject.get_dispatch_zip(dispatch_id: dispatch_options[:dispatch_id], type: "SCORM2004-3RD")
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.result.type).to eq "SCORM2004-3RD"

        zip_contents = Zip::File.open_buffer(StringIO.new(response.result.body)).each_entry.map(&:name)
        expect(zip_contents).to include("blank.html", "configuration.js", "dispatch.html", "goodbye.html") # sampling
      end
    end

    it "works when type is AICC" do
      response = subject.get_dispatch_zip(dispatch_id: dispatch_options[:dispatch_id], type: "AICC")
      aggregate_failures do
        expect(response.success?).to eq true
        expect(response.result.type).to eq "AICC"

        zip_contents = Zip::File.open_buffer(StringIO.new(response.result.body)).each_entry.map(&:name)
        expect(zip_contents).to include("blank.html", "configuration.js", "dispatch.html", "goodbye.html") # sampling
      end
    end

    it "fails given an invalid id" do
      response = subject.get_dispatch_zip(dispatch_id: "nonexistent-dispatch")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.result).to eq nil
        expect(response.message).to eq "No dispatches found with ID: nonexistent-dispatch"
      end
    end

    it "fails given an invalid type" do
      response = subject.get_dispatch_zip(dispatch_id: dispatch_options[:dispatch_id], type: "OOPS")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 500
        expect(response.result).to eq nil
        expect(response.message).to eq "The value 'OOPS' is not a valid Dispatch Type."
      end
    end
  end

  describe "#get_dispatch_registration_count" do
    before do
      subject.delete_dispatch_registration_count(dispatch_id: dispatch_options[:dispatch_id])
    end

    let(:response) { subject.get_dispatch_registration_count(dispatch_id: dispatch_options[:dispatch_id]) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the dispatch attributes" do
        dispatch = response.result
        aggregate_failures do
          expect(dispatch.id).to eq dispatch_options[:dispatch_id]
          expect(dispatch.registration_count).to eq 0
          expect(dispatch.last_reset_at).to be_a(Time)
        end
      end
    end

    it "fails when id is invalid" do
      response = subject.get_dispatch_registration_count(dispatch_id: "nonexistent-dispatch")
      aggregate_failures do
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/No dispatches found with ID: nonexistent-dispatch/)
        expect(response.result).to eq nil
      end
    end
  end

  describe "#delete_dispatch_registration_count" do
    let(:response) { subject.delete_dispatch_registration_count(dispatch_id: dispatch_options[:dispatch_id]) }

    it "is successful" do
      expect(response.success?).to eq true
    end

    it "succeeds even when id is invalid" do
      response = subject.delete_dispatch_registration_count(dispatch_id: "nonexistent-dispatch")
      expect(response.success?).to eq true
    end
  end
end
