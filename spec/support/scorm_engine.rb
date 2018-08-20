module ScormEngineHelpers
  #
  # If a real scorm engine is available this method will disable VCR and
  # execute the passed block.  It is useful for when we need to ensure certain
  # records are present in SCORM engine, but we do not want them recorded as
  # the act of recording would break later expectations. That is if we record
  # importing a course and play it back other tests that expect the actual
  # record to exist in SCORM will fail.
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
  # Check to see if a scorm engine is available. Probably true while developing
  # locally, definitely not true in Travis.
  #
  def scorm_engine_is_available?
    ENV["SCORM_ENGINE_IS_AVAILABLE"] == "true"
  end

  #
  # Ensure that the specified course exists in SCORM engine. Will import course
  # if not present.
  #
  def ensure_course_exists(options = {})
    response = options[:client].get_courses(course_id: options[:course_id])
    return if response&.results&.first&.id == options[:course_id]
    import_course(options)
  end

  #
  # Attempt to import a course to SCORM engine.
  #
  def import_course(options = {})
    options = { key: "RuntimeBasicCalls_SCORM20043rdEdition", may_create_new_version: true }.merge(options)

    url = "https://github.com/phallstrom/scorm_engine/raw/master/spec/fixtures/zip/#{options[:key]}.zip"

    import = options[:client].post_course_import(course_id: options[:course_id], url: url, may_create_new_version: options[:may_create_new_version])

    if import.success?
      loop do
        import = options[:client].get_course_import(id: import.result.id)
        break unless import.success? && import.result.running?
        sleep 5
      end
    end

    import
  end

  #
  # Ensure that the specified registration exists in SCORM engine. Course
  # must exist first.
  #
  def ensure_registration_exists(options = {})
    response = options[:client].get_registration_exists(registration_id: options[:registration_id])
    return if response&.result
    options[:client].post_registration(options)
  end

  #
  # Ensure that the specified destination exists in SCORM engine.
  #
  def ensure_destination_exists(options = {})
    response = options[:client].get_destination(destination_id: options[:destination_id])
    if response&.result.nil?
      options[:client].post_destination(options)
    elsif options.key?(:name) && response&.result&.name != options[:name]
      options[:client].put_destination(options)
    end
  end

end

RSpec.configure do |c|
  c.include ScormEngineHelpers
end
