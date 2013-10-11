require 'spec_helper'

describe '/' do

  it 'should render' do
    get '/'
    last_response.should be_ok
  end

end
