# frozen_string_literal: true
require 'rails_helper'

describe 'Component Rendering', type: :view do
  before(:each) do
    users = [OpenStruct.new(name: 'Viny')]
    users << OpenStruct.new(name: 'Pedro')
    assign(:users, users)

    render file: 'fixtures/user_listing'
  end

  it 'Renders the component' do
    expect(rendered).to have_css('td', text: 'Viny')
    expect(rendered).to have_css('td', text: 'Pedro')

    expect(rendered).to have_css('header')
    expect(rendered).to have_css('.notice', count: 2)
  end
end
