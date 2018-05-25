# Reset the ScormEngine configuration before every example in case the previous
# example intentionally changed it (perhaps to test invalid settings).
RSpec.configure do |config|
  config.before do
    ScormEngine.configuration.reset
  end
end
