module ScormEngineHelpers
  #
  #
  #
  def against_real_scorm_engine
    return unless scorm_engine_is_available?

    cassette = VCR.eject_cassette
    VCR.turned_off do
      yield
    end
    VCR.insert_cassette(cassette.name, cassette.instance_variable_get(:@options))
  end

  #
  #
  #
  def scorm_engine_is_available?
    ENV["SCORM_ENGINE_IS_AVAILABLE"] == "true"
  end

  #
  #
  #
  def ensure_course_exists(options = {})
    response = options[:client].courses(course_id: options[:course_id])
    return if response&.results.first&.id == options[:course_id]
    import_course(options)
  end

  #
  #
  #
  def import_course(options = {})
    options = {key: "RuntimeBasicCalls_SCORM20043rdEdition", may_create_new_version: true}.merge(options)

    url = "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/#{options[:key]}.zip"

    import = options[:client].course_import(course_id: options[:course_id], url: url, may_create_new_version: options[:may_create_new_version])

    if import.success?
      loop do
        import = options[:client].course_import_status(id: import.result.id)
        break unless import.success? && import.result.running?
        sleep 5
      end
    end

    import
  end
end

RSpec.configure do |c| 
  c.include ScormEngineHelpers
end
