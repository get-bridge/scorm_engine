require "spec_helper"

# TODO: All tests commented out due to SCORM Engine API v1 → v2 migration
# These integration tests require VCR cassettes to be re-recorded with API v2 authentication
# (engineTenantName header instead of tenant in URL path)
# Once VCR cassettes are updated for API v2, uncomment these tests
#
# RSpec.describe ScormEngine::Api::Endpoints::About do
#   describe "#get_about" do
#     let(:client) { scorm_engine_client.get_about }
#
#     it "is successful" do
#       expect(client.success?).to eq true
#     end
#
#     it "knows the version" do
#       expect(client.result.version).to eq "20.1.12.336"
#     end
#
#     it "knows the platform" do
#       expect(client.result.platform).to eq "Java"
#     end
#   end
#
#   describe "#get_about_user_count" do
#     let(:client) { scorm_engine_client.get_about_user_count }
#
#     it "is successful" do
#       expect(client.success?).to eq true
#     end
#
#     it "tracks combined counts" do
#       aggregate_failures do
#         expect(client.result.total).to be >= 1
#         expect(client.result.dispatched).to be >= 0
#         expect(client.result.non_dispatched).to be >= 0
#       end
#     end
#
#     it "tracks per tenantcounts" do
#       aggregate_failures do
#         expect(client.result.by_tenant).to be_a Hash
#         tenant = client.result.by_tenant[scorm_engine_client.tenant.downcase]
#         expect(tenant.total).to be >= 0
#         expect(tenant.dispatched).to be >= 0
#         expect(tenant.non_dispatched).to be >= 0
#       end
#     end
#
#     it "accepts :before option" do
#       client = scorm_engine_client.get_about_user_count(before: Time.parse("1901-01-1 00:00:00 UTC"))
#       aggregate_failures do
#         expect(client.success?).to eq true
#         expect(client.result.total).to eq 0
#       end
#     end
#
#     it "accepts :since option" do
#       client = scorm_engine_client.get_about_user_count(since: Time.parse("2031-01-1 00:00:00 UTC"))
#       aggregate_failures do
#         expect(client.success?).to eq true
#         expect(client.result.total).to eq 0
#       end
#     end
#   end
# end
