module ComponentParty
  # Represents a component with a template, style and javascript file
  class Component
    class InvalidVMError < StandardError; end
    class InvalidVMError < StandardError; end
    class << self
      def helper_object
        @helper_object = Class.new(ActionView::Base) do
          include ::Rails.application.routes.url_helpers
          include ::Rails.application.routes.mounted_helpers
        end.new
      end

      def helper_vm_params
        {
          h: helper_object,
          helper: helper_object
        }
      end
    end

    attr_reader :view_model_data
    attr_reader :path
    attr_reader :parent_component

    def initialize(path:, view_model_data: {}, lookup_context: nil)
      @path = path.to_s.gsub(%r{^(/)|^(./)}, '')
      @lookup_context = lookup_context
      @view_model_data = view_model_data
    end

    def render(view_context = view_model, options = {})
      renderer.render(view_context, options)
    end

    def renderer
      ComponentParty::Component::Renderer.new(self)
    end

    def lookup_context
      @lookup_context ||= ActionView::LookupContext.new(
        [
          Rails.root.join(ComponentParty.configuration.components_path)
        ]
      )
    end

    def view_model
      return @view_model if @view_model

      vm_class = find_custom_vm_class
      vm_class ||= ComponentParty::Component::ViewModel

      @view_model = vm_class.new(**view_model_data.merge(view_model_default_data))
    end

    def view_model_default_data
      self.class.helper_vm_params.merge(
        # lookup_context is necessary for when there is an exception in our template
        # this is used in order to better describe the error stack
        lookup_context: lookup_context,
        # component is necessary in order to keep track of the component
        # tree so we can do relative imports fetching the parent component path
        component: self
      )
    end

    private

    def find_custom_vm_class
      vm_file_path = Pathname.new(path).join(ComponentParty.configuration.view_model_file_name)

      vm_class = begin
                   ActiveSupport::Inflector.camelize(vm_file_path).constantize
                 rescue StandardError
                   nil
                 end

      if vm_class
        unless vm_class.ancestors.include?(ComponentParty::Component::ViewModel)
          error_msg = "#{vm_class} cannot be used as a ViewModel. Make sure that it inherits from ComponentParty::Component::ViewModel."
          raise ComponentParty::Component::InvalidVMError, error_msg
        end
      end

      vm_class
    end
  end
end
