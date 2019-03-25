require 'actioncomponent/importer_helper'
require 'actioncomponent/component'
require 'actioncomponent/component/view_model'
require 'actioncomponent/component/renderer'
require 'actioncomponent/railtie'

module ActionComponent
  # Configuration class for ActionComponent
  # @attr components_path [String] Components folder path (defaults to 'app/components')
  # @attr components_path [String] Component's template file name (defaults to 'template')
  class Configuration
    attr_accessor :components_path
    attr_accessor :template_file_name
    attr_accessor :view_model_file_name

    def initialize
      @components_path = 'app/components'
      @template_file_name = 'template'
      @view_model_file_name = 'view_model'
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end