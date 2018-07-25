RSpec.describe ScormEngine::Api::Endpoints::Courses do
  let(:subject) { scorm_engine_client }

  before do
    against_real_scorm_engine do
      ensure_course_exists(client: subject, course_id: "testing-golf-explained")
    end
  end

  describe "#get_courses" do
    let(:courses) { subject.get_courses }

    it "is successful" do
      expect(courses.success?).to eq true
    end

    describe "results" do
      it "is an enumerator of Course models" do
        expect(courses.results).to be_a Enumerator
        expect(courses.results.first).to be_a ScormEngine::Models::Course
      end

      it "sucessfully creates the Course attributes" do
        aggregate_failures do
          course = courses.results.detect {|c| c.id == "testing-golf-explained" }
          expect(course.version).to be >= 0
          expect(course.title).to eq "Golf Explained - Run-time Basic Calls"
          expect(course.registration_count).to eq 0
          expect(course.updated).to be_a Time
          expect(course.description).to eq nil
        end
      end
    end

    describe ":course_id option" do
      it "fetches a single course, but perhaps multiple versions" do
        response = subject.get_courses(course_id: "testing-golf-explained")
        expect(response.results.all? { |c| c.title == "Golf Explained - Run-time Basic Calls" }).to eq true
      end

      it "returns 404 when ID is invalid" do
        response = subject.get_courses(course_id: "invalid-bogus")
        expect(response.success?).to eq false
        expect(response.status).to eq 404
        expect(response.message).to match(/External Package ID 'invalid-bogus'/)
      end
    end

    describe ":since option" do
      it "works" do
        courses = subject.get_courses(since: Time.parse("2000-01-1 00:00:00 UTC"))
        aggregate_failures do
          expect(courses.success?).to eq true
          expect(courses.results.to_a.size).to be >= 0
        end
      end

      it "fails when passed an invalid value" do
        courses = subject.get_courses(since: "invalid")
        aggregate_failures do
          expect(courses.success?).to eq false
          expect(courses.status).to eq 400
          expect(courses.results.to_a).to eq []
          expect(courses.message).to match(/'invalid' is either not a timestamp or seems to be not formatted according to ISO 8601/)
        end
      end
    end

    describe ":more option (pagination)" do
      before do
        against_real_scorm_engine do
          11.times do |idx|
            ensure_course_exists(client: subject, course_id: "paginated-course-#{idx}")
          end
        end
      end

      it "returns the :more key in the raw response" do
        expect(subject.get_courses.raw_response.body["more"]).to match(%r{https?://.*&more=.+})
      end

      it "returns all the courses" do
        expect(subject.get_courses.results.to_a.size).to be >= 11 # there may be other ones beyond those we just added
      end
    end
  end

  describe "#delete_course" do
    before do
      against_real_scorm_engine do
        ensure_course_exists(client: subject, course_id: "course-to-be-deleted")
      end
    end

    it "works" do
      response = subject.delete_course(course_id: "course-to-be-deleted")
      expect(response.success?).to eq true
      expect(response.status).to eq 204
    end

    it "raises ArgumentError when :course_id is missing" do
      expect { subject.delete_course }.to raise_error(ArgumentError, /:course_id missing/)
    end

    it "fails when id is invalid" do
      response = subject.delete_course(course_id: "nonexistent-course")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end
  end

  describe "#get_course_detail" do
    let(:response) { subject.get_course_detail(course_id: "testing-golf-explained") }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "sucessfully creates the Course attributes" do
        aggregate_failures do
          course = response.result
          expect(course.version).to be >= 0
          expect(course.title).to eq "Golf Explained - Run-time Basic Calls"
          expect(course.registration_count).to be >= 0
          expect(course.updated).to be_a Time
          expect(course.description).to eq nil
        end
      end
    end
  end

  describe "#get_course_preview" do
    let(:response) { subject.get_course_preview(course_id: "testing-golf-explained", redirect_on_exit_url: "https://example.com") }

    it "is successful" do
      expect(response.success?).to eq true
    end

    describe "results" do
      it "returns a URL string" do
        url = response.result
        expect(url).to match(%r{/defaultui/launch.jsp\?.*testing-golf-explained.*RedirectOnExitUrl=https%3A%2F%2Fexample.com})
      end
    end

    it "fails when id is invalid" do
      response = subject.get_course_preview(course_id: "nonexistent-course")
      expect(response.success?).to eq false
      expect(response.status).to eq 404
      expect(response.message).to match(/External Package ID 'nonexistent-course'/)
    end
  end
end
