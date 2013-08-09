require_relative 'spec_helper'
require_relative 'redmine_adapter_mock'

describe 'Splitter' do
  before(:each) do
    @redmine_adapter_mock = RedmineAdapterMock.new
    @splitter = Splitter.new(@redmine_adapter_mock)
    @tm = RedmineAdapterMock::TimeEntryMock
  end

  it 'should not assign invalid entries' do
    e = @tm.new(916, "Bla bla bla", 77)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    e.issue_id.should == 916
    e.comments.should == "Bla bla bla"
    e.activity_id.should == 77
    e.saved?.should == false
  end

  it 'should not assign unassignable entries' do
    e = @tm.new(916, "3242134: Bla bla bla", 77)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    e.issue_id.should == 916
    e.comments.should == "3242134: Bla bla bla"
    e.activity_id.should == 77
    e.saved?.should == false
  end

  it 'should assign valid time entries 1' do
    e = @tm.new(916, "3242134: 777 Bla bla bla", 77)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    e.issue_id.should == 777
    e.comments.should == "3242134: Bla bla bla"
    e.activity_id.should == 77
    e.saved?.should == true
  end

  it 'should map the activity' do
    e = @tm.new(916, "3242134: 777 Bla bla bla : Blub", 77)
    @redmine_adapter_mock.mock_time_entries([e])
    @redmine_adapter_mock.activities_mapping['Blub'] = 999
    @splitter.split_time_entries
    e.issue_id.should == 777
    e.comments.should == "3242134: Bla bla bla"
    e.activity_id.should == 999
    e.saved?.should == true
  end

  it 'should not map an invalid activity' do
    e = @tm.new(916, "3242134: 777 Bla bla bla : Nanana", 77)
    @redmine_adapter_mock.mock_time_entries([e])
    @splitter.split_time_entries
    e.issue_id.should == 777
    e.comments.should == "3242134: Bla bla bla: Nanana"
    e.activity_id.should == 77
    e.saved?.should == true
  end
end
