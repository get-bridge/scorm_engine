require "base64"
require "vcr"
require "set"

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr"
  c.hook_into :faraday
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :once }
  c.filter_sensitive_data("<SCORM_ENGINE_HOST>") { ENV["SCORM_ENGINE_HOST"] }
  c.filter_sensitive_data("<BASIC_AUTH>") { Base64.urlsafe_encode64("#{ENV["SCORM_ENGINE_USERNAME"]}:#{ENV["SCORM_ENGINE_PASSWORD"]}") }
end

#
# Track every cassette used so that we can optionally (only if doing a full spec suite)
# print out no longer used cassettes in an easy to git/rm format.
#
INSERTED_CASSETTES = Set.new
module CassetteReporter
  def insert_cassette(name, options = {})
    INSERTED_CASSETTES << VCR::Cassette.new(name, options).file
    super
  end
end
VCR.extend(CassetteReporter)

RSpec.configure do |config|
  config.after(:suite) do
    if config.instance_variable_get(:@files_or_directories_to_run) == ["spec"]
      files = Dir["#{VCR.configuration.cassette_library_dir}/**/*.yml"] - INSERTED_CASSETTES.to_a
      unless files.empty?
        puts "\nThe following VCR cassettes are no longer in use:\n\n"
        gem_directory = File.expand_path("#{File.dirname(__FILE__)}/../../")
        files.uniq.each_with_index do |expanded_path, idx|
          relative_path = expanded_path.sub(%r{^#{gem_directory}/}, "")
          backslash = (idx == files.size - 1) ? "" : "\\"
          if idx.zero?
            puts "  git rm -f #{relative_path} #{backslash}"
          else
            puts "            #{relative_path} #{backslash}"
          end
        end
      end
    end
  end
end

# A helper used by specs to potentially sleep while we wait for async SCORM
# jobs to process before checking their status. This is necessary because
# otherwise VCR will cache the first status request and never update.
def recording_vcr?
  ENV.key?("RECORDING_VCR")
end
