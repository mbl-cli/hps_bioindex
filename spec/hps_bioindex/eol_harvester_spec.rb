require_relative '../spec_helper'

describe HpsBioindex::EolHarvester do
  subject { HpsBioindex::EolHarvester.new }
  
  describe '#new' do
    it { should be_kind_of HpsBioindex::EolHarvester }
  end

  describe '.harvest' do
    let!(:outlink) { FactoryGirl.create(:outlink) }
    let!(:harvest) { subject.harvest }

    before(:all) { truncate_tables }
    it do
      FactoryGirl.create(:outlink)
      require 'ruby-debug'; debugger
      expect(EolData.count).to eq 1
    end
    it { expects(EolDataSynonym.count).to eq 1 }
    it { expect(EolDataVernacular.count).to eq 1 }
  end
end
