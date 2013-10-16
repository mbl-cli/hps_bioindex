require_relative '../integration_helper'

describe 'home' do
  it 'should load page' do
    visit '/'
    page.should have_selector('#alphabet')
  end
end
