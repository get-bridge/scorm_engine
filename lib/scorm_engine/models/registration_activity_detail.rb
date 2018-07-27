module ScormEngine
  module Models
    class RegistrationActivityDetail
      attr_accessor :options
      private :options

      # TODO: Not sure we want this to be settable. Will depend on how we go
      # about creating/updating records. For now it makes it easier to create
      # instances from API options hash.
      attr_accessor :id, :children, :runtime_interactions

      def self.new_from_api(options = {})
        this = new

        this.options = options.dup
        this.id = options["id"]

        this.runtime_interactions = get_runtime_interactions_from_api(options)

        this.children = options.fetch("children", []).map { |e| new_from_api(e) }

        this
      end

      def all_runtime_interactions
        (runtime_interactions + children.map(&:all_runtime_interactions)).flatten
      end

      def self.get_runtime_interactions_from_api(options)
        options
          .fetch("runtime", {})
          .fetch("runtimeInteractions", [])
          .map { |e| RegistrationRuntimeInteraction.new_from_api(e) }
      end
    end
  end
end
