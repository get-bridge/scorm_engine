# A helper to easily instantiate a ScormEngine::Client in a tenant namespaced
# to "ScormEngineGemTesting" to help avoid conflicts with other testers/users
# of the server.
def scorm_engine_client(suffix = "default")
  ScormEngine::Client.new(tenant: "ScormEngineGemTesting-#{suffix}")
end
