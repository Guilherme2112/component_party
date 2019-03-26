require "spec_helper"

describe ActionComponent do
  describe "#configure" do
    before do
      ActionComponent.configure do |config|
        config.components_path = 'app/components'
      end
    end

    describe 'components_path configuration' do
      specify 'it has /app/components as default' do
        expect(ActionComponent.configuration.components_path).to eq('app/components')
      end
    end

    describe 'template_file_name configuration' do
      specify 'it has template as default' do
        expect(ActionComponent.configuration.template_file_name).to eq('template')
      end
    end

    describe 'view_model_file_name configuration' do
      specify 'it has view_model as default' do
        expect(ActionComponent.configuration.view_model_file_name).to eq('view_model')
      end
    end

    describe 'component_folder_for_actions configuration' do
      specify 'it has pages as default' do
        expect(ActionComponent.configuration.component_folder_for_actions).to eq('pages')
      end
    end
  end
end
