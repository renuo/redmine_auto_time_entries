require_relative 'spec_helper'
require_relative 'redmine_adapter_mock'
require 'date'

describe 'Splitter' do
  before(:each) do
    @redmine_adapter_mock = RedmineAdapterMock.new
    @splitter = Splitter.new(@redmine_adapter_mock)
    @tm = RedmineAdapterMock::TimeEntryMock
  end

  it 'should not assign invalid entries' do
    e = @tm.new(916, "Bla bla bla", 77, 2.5)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    expect(e.issue_id).to eq 916
    expect(e.comments).to eq "Bla bla bla"
    expect(e.activity_id).to eq 77
    expect(e.hours).to eq 2.5
    expect(e.saved?).to eq false
    expect(@redmine_adapter_mock.time_entries.count).to eq 1
    expect(@redmine_adapter_mock.time_entries.first).to eq e
  end

  it 'should not assign unassignable entries' do
    e = @tm.new(916, "3242134: Bla bla bla", 77, 2.5)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    expect(e.issue_id).to eq 916
    expect(e.comments).to eq "3242134: Bla bla bla"
    expect(e.activity_id).to eq 77
    expect(e.hours).to eq 2.5
    expect(e.saved?).to eq false
    expect(@redmine_adapter_mock.time_entries.count).to eq 1
    expect(@redmine_adapter_mock.time_entries.first).to eq e
  end

  it 'should assign valid time entries 1' do
    e = @tm.new(916, "3242134: 777 Bla bla bla", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    expect(e.issue_id).to eq 777
    expect(e.comments).to eq "3242134: Bla bla bla"
    expect(e.activity_id).to eq 77
    expect(e.saved?).to eq true
    expect(@redmine_adapter_mock.time_entries.count).to eq 1
    expect(@redmine_adapter_mock.time_entries.first).to eq e
  end

  it 'should clear the project_id when reassigning the issue' do
    e = @tm.new(916, "3242134: 777 Bla bla bla", 77, 1.0, 123, false, Date.new(2018, 1, 2), 24)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    expect(e.project_id.nil?).to eq true
  end

  it 'should map the activity' do
    e = @tm.new(916, "3242134: 777 Bla bla bla : Blub", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries([e])
    @redmine_adapter_mock.activities_mapping['Blub'] = 999
    @splitter.split_time_entries
    expect(e.issue_id).to eq 777
    expect(e.comments).to eq "3242134: Bla bla bla"
    expect(e.activity_id).to eq 999
    expect(e.saved?).to eq true
    expect(@redmine_adapter_mock.time_entries.count).to eq 1
    expect(@redmine_adapter_mock.time_entries.first).to eq e
  end

  it 'should not map an invalid activity' do
    e = @tm.new(916, "3242134: 777 Bla bla bla : Nanana", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries([e])
    @splitter.split_time_entries
    expect(e.issue_id).to eq 777
    expect(e.comments).to eq "3242134: Bla bla bla: Nanana"
    expect(e.activity_id).to eq 77
    expect(e.saved?).to eq true
    expect(@redmine_adapter_mock.time_entries.count).to eq 1
    expect(@redmine_adapter_mock.time_entries.first).to eq e
  end

  it 'should split the hours for multiple time entries' do
    e = @tm.new(916, "3242134: d 777 888 999 Bla bla bla", 77, 3.0)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    expect(@redmine_adapter_mock.time_entries.count).to eq 3
    e1 = @redmine_adapter_mock.time_entries[0]
    e2 = @redmine_adapter_mock.time_entries[1]
    e3 = @redmine_adapter_mock.time_entries[2]
    expect(e1).to eq e

    expect(e1.issue_id).to eq 777
    expect(e1.comments).to eq "3242134: Bla bla bla"
    expect(e1.activity_id).to eq 77
    expect(e1.saved?).to eq true
    expect(e1.hours).to eq 1.0

    expect(e2.issue_id).to eq 888
    expect(e2.comments).to eq "3242134: Bla bla bla"
    expect(e2.activity_id).to eq 77
    expect(e2.saved?).to eq true
    expect(e2.hours).to eq 1.0

    expect(e3.issue_id).to eq 999
    expect(e3.comments).to eq "3242134: Bla bla bla"
    expect(e3.activity_id).to eq 77
    expect(e3.saved?).to eq true
    expect(e3.hours).to eq 1.0
  end

  it 'should split the hours for multiple time entries' do
    e = @tm.new(916, "3242134: d 777 888 Bla bla bla", 77, 3.0)
    @redmine_adapter_mock.mock_time_entries(
        [e]
    )
    @splitter.split_time_entries
    expect(@redmine_adapter_mock.time_entries.count).to eq 2
    e1 = @redmine_adapter_mock.time_entries[0]
    e2 = @redmine_adapter_mock.time_entries[1]
    expect(e1).to eq e

    expect(e1.issue_id).to eq 777
    expect(e1.comments).to eq "3242134: Bla bla bla"
    expect(e1.activity_id).to eq 77
    expect(e1.saved?).to eq true
    expect(e1.hours).to eq 1.5

    expect(e2.issue_id).to eq 888
    expect(e2.comments).to eq "3242134: Bla bla bla"
    expect(e2.activity_id).to eq 77
    expect(e2.saved?).to eq true
    expect(e2.hours).to eq 1.5
  end

  it 'should assign spent on' do
    e = @tm.new(916, "3242134: 777 Bla bla bla : Tag : 2017-04-25T09:02:30+00: 00", 77, 1.0)
    @redmine_adapter_mock.mock_time_entries([e])
    @splitter.split_time_entries
    expect(e.comments).to eq "3242134: Bla bla bla : Tag : 2017-04-25T09:02:30+00: 00"
    expect(e.spent_on).to eq Date.new(2017, 4, 25)
  end

  it 'should not assign spent on if not present' do
    e = @tm.new(916, "3242134: 777 Bla bla bla", 77, 1.0)
    e.spent_on = Date.new(2017, 4, 22)
    @redmine_adapter_mock.mock_time_entries([e])
    @splitter.split_time_entries
    expect(e.comments).to eq "3242134: Bla bla bla"
    expect(e.spent_on).to eq Date.new(2017, 4, 22)
  end

  it 'should not halt other entries when first is invalid' do
    entry1 = @tm.new(916, "3242134: 777 Bla bla bla", 77, 1.0)
    entry2 = @tm.new(916, "3242135: 888 Bla bla bla", 77, 1.0)
    allow(entry1).to receive(:save).and_return(false)
    @redmine_adapter_mock.mock_time_entries([entry1, entry2])
    @splitter.split_time_entries
    expect(entry1.issue_id).to eq 777
    expect(entry1.saved?).to eq false
    expect(entry2.issue_id).to eq 888
    expect(entry2.saved?).to eq true
  end
end
