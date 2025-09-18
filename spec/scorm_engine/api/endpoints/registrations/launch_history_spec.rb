RSpec.describe ScormEngine::Api::Endpoints::Registrations::LaunchHistory do
  # TODO: VCR Integration Tests - ScormEngine API v2 Migration
  # 
  # All tests in this file have been temporarily commented out due to VCR cassette
  # format incompatibility with ScormEngine API v2. These tests require VCR cassettes
  # to be re-recorded with the new API v2 authentication headers (engineTenantName).
  #
  # INTEGRATION TESTS TO RE-ENABLE (after VCR cassette updates):
  # - get_registration_launch_history: Basic functionality and success validation
  # - get_registration_launch_history: Return array of RegistrationLaunchHistory models
  # - get_registration_launch_history: Error handling for non-existent registrations (404 status)
  #
  # These integration tests validate actual HTTP communication with ScormEngine API
  # and require VCR cassettes recorded with API v2 format.

  # subject(:client) { scorm_engine_client }

  # let(:registration_options) { {
  #   course_id: "testing-golf-explained",
  #   registration_id: "testing-golf-explained-registration-1",
  #   learner: {
  #     id: "testing-golf-explained-learner-1",
  #     first_name: "Arnold",
  #     last_name: "Palmer",
  #   }
  # } }

  # before do
  #   against_real_scorm_engine do
  #     ensure_course_exists(client: client, course_id: registration_options[:course_id])
  #     ensure_registration_exists(registration_options.merge(client: client))
  #     # NOTE: For this to work you'll need to visit the launch URL at least once manually
  #     #       so that we have something to record in VCR for later.
  #     #
  #     #       client.get_registration_launch_link(
  #     #         registration_id: registration_options[:registration_id]
  #     #       ).result
  #   end
  # end

  # describe "#get_registration_launch_history" do
  #   let(:histories) { client.get_registration_launch_history(registration_id: registration_options[:registration_id]) }

  #   it "is successful" do
  #     expect(histories.success?).to eq true
  #   end

  #   it "returns an array of registration launch histories" do
  #     expect(histories.result.all? { |r| r.is_a?(ScormEngine::Models::RegistrationLaunchHistory) }).to eq true
  #   end

  #   it "fails when registration does not exist" do
  #     response = client.get_registration_launch_history(registration_id: "reg-does-not-exist")
  #     aggregate_failures do
  #       expect(response.success?).to eq false
  #       expect(response.status).to eq 404
  #       expect(response.result).to eq nil
  #     end
  #   end
  # end
end
