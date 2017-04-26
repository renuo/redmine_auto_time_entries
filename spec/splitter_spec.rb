require_relative 'spec_helper'
require_relative 'redmine_adapter_mock'

describe 'Splitter' do
  before(:each) do
    @redmine_adapter_mock = RedmineAdapterMock.new
    @splitter = Splitter.new(@redmine_adapter_mock)
    @tm = RedmineAdapterMock::TimeEntryMock
  end

  it 'should not assign invalid entries' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "Bla bla bla", 77, 2.5)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    e.issue_id.should == 916
    e.comments.should == "Bla bla bla"
    e.activity_id.should == 77
    e.hours.should == 2.5
    e.saved?.should == false
    @redmine_adapter_mock.time_entries.count.should == 1
    @redmine_adapter_mock.time_entries.first.should === e
  end

  it 'should not assign unassignable entries' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "3242134: Bla bla bla", 77, 2.5)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    e.issue_id.should == 916
    e.comments.should == "3242134: Bla bla bla"
    e.activity_id.should == 77
    e.hours.should == 2.5
    e.saved?.should == false
    @redmine_adapter_mock.time_entries.count.should == 1
    @redmine_adapter_mock.time_entries.first.should === e
  end

  it 'should assign valid time entries 1' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "3242134: 777 Bla bla bla", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    e.issue_id.should == 777
    e.comments.should == "3242134: Bla bla bla"
    e.activity_id.should == 77
    e.saved?.should == true
    @redmine_adapter_mock.time_entries.count.should == 1
    @redmine_adapter_mock.time_entries.first.should === e
  end

  it 'should map the activity' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "3242134: 777 Bla bla bla : Blub", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries([e])
    @redmine_adapter_mock.activities_mapping['Blub'] = 999
    @splitter.split_time_entries
    e.issue_id.should == 777
    e.comments.should == "3242134: Bla bla bla"
    e.activity_id.should == 999
    e.saved?.should == true
    @redmine_adapter_mock.time_entries.count.should == 1
    @redmine_adapter_mock.time_entries.first.should === e
  end

  it 'should not map an invalid activity' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "3242134: 777 Bla bla bla : Nanana", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries([e])
    @splitter.split_time_entries
    e.issue_id.should == 777
    e.comments.should == "3242134: Bla bla bla: Nanana"
    e.activity_id.should == 77
    e.saved?.should == true
    @redmine_adapter_mock.time_entries.count.should == 1
    @redmine_adapter_mock.time_entries.first.should === e
  end

  it 'should split the hours for multiple time entries' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "3242134: d 777 888 999 Bla bla bla", 77, 3.0)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    @redmine_adapter_mock.time_entries.count.should == 3
    e1 = @redmine_adapter_mock.time_entries[0]
    e2 = @redmine_adapter_mock.time_entries[1]
    e3 = @redmine_adapter_mock.time_entries[2]
    e1.should === e

    e1.issue_id.should == 777
    e1.comments.should == "3242134: Bla bla bla"
    e1.activity_id.should == 77
    e1.saved?.should == true
    e1.hours.should == 1.0

    e2.issue_id.should == 888
    e2.comments.should == "3242134: Bla bla bla"
    e2.activity_id.should == 77
    e2.saved?.should == true
    e2.hours.should == 1.0

    e3.issue_id.should == 999
    e3.comments.should == "3242134: Bla bla bla"
    e3.activity_id.should == 77
    e3.saved?.should == true
    e3.hours.should == 1.0
  end

  it 'should split the hours for multiple time entries' do
    e = @tm.new(916,"2017-04-25T09:02:30+00: 00", "3242134: d 777 888 Bla bla bla", 77, 3.0)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    @redmine_adapter_mock.time_entries.count.should == 2
    e1 = @redmine_adapter_mock.time_entries[0]
    e2 = @redmine_adapter_mock.time_entries[1]
    e1.should === e

    e1.issue_id.should == 777
    e1.comments.should == "3242134: Bla bla bla"
    e1.activity_id.should == 77
    e1.saved?.should == true
    e1.hours.should == 1.5

    e2.issue_id.should == 888
    e2.comments.should == "3242134: Bla bla bla"
    e2.activity_id.should == 77
    e2.saved?.should == true
    e2.hours.should == 1.5
  end
end
