require_relative 'spec_helper'
require 'date'

describe 'Assigner' do
  it 'should assign toggle id' do
    a = Assigner.new '92345678: Redmine Auto Time Entries : Entwicklung'
    a.toggle_id.should == 92345678
  end

  it 'should assign ticket 1' do
    a = Assigner.new '92345678: 741 Bla bla bla'
    a.issue_ids.first.should == 741
    a.issue_ids.count.should == 1
  end

  it 'should assign ticket 2' do
    a = Assigner.new '92345678: 742'
    a.issue_ids.first.should == 742
    a.issue_ids.count.should == 1
  end

  it 'should not assign ticket if nil' do
    a = Assigner.new '92345678: Foo bar foo bar'
    a.issue_ids.first.should == nil
  end

  it 'should assign comment without ticket' do
    a = Assigner.new '92345678: Foo bar foo bar'
    a.issue_ids.first.should == nil
    a.comment.should == 'Foo bar foo bar'
  end

  it 'should assign comment with ticket' do
    a = Assigner.new '92345678: 742 Foo bar foo bar'
    a.comment.should == 'Foo bar foo bar'
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Feature #7682 Implement toggl directly from redmine'
    a.comment.should == 'Implement toggl directly from redmine'
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Whatever #7682 Implement toggl directly from redmine'
    a.comment.should == 'Implement toggl directly from redmine'
  end

  it 'should assign comment with multiple tickets fake' do
    a = Assigner.new '92345678: 742 333 222 421 Foo bar foo bar'
    a.comment.should == '333 222 421 Foo bar foo bar'
  end

  it 'should assign comment with multiple tickets' do
    a = Assigner.new '92345678: d 742 333 222 421 Foo bar foo bar'
    a.comment.should == 'Foo bar foo bar'
  end

  it 'should assign comment with multiple tickets' do
    a = Assigner.new '92345678: d 742 333 222 421Foo bar foo bar'
    a.comment.should == '421Foo bar foo bar'
  end

  it 'should assign comment with activity 1' do
    a = Assigner.new '92345678: 742 Foo bar foo bar : Entwicklung'
    a.comment.should == 'Foo bar foo bar'
  end

  it 'should assign comment with activity 2' do
    a = Assigner.new '92345678: 742 Foo bar foo bar: something important : Entwicklung'
    a.comment.should == 'Foo bar foo bar: something important'
  end

  it 'should be valid if toggle_id is present' do
    a = Assigner.new '92345678: 742 Foo bar foo bar'
    a.valid?.should == true
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Feature #7682 Implement toggl directly from redmine'
    a.valid?.should == true
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Whatever #7682 Implement toggl directly from redmine'
    a.valid?.should == true
  end

  it 'should be invalid if toggle_id is missing 1' do
    a = Assigner.new '742 Foo bar foo bar'
    a.valid?.should == false
  end

  it 'should be invalid if toggle_id is missing 2' do
    a = Assigner.new 'Foo bar foo bar'
    a.valid?.should == false
  end

  it 'should be assignable if a ticket id can be found' do
    a = Assigner.new '92345678: 777 Foo bar foo bar'
    a.assignable?.should == true
  end

  it 'should not be assignable if a ticket id cannot be found' do
    a = Assigner.new '92345678: Foo bar foo bar'
    a.assignable?.should == false
  end

  it 'should filter an activity' do
    a = Assigner.new '92345678: Foo bar foo bar : Entwicklung'
    a.activity.should == 'Entwicklung'
  end

  it 'should filter an activity with complicated comment' do
    a = Assigner.new '92345678: Foo bar foo bar : something important : Entwicklung'
    a.activity.should == 'Entwicklung'
  end

  it 'should leave activity empty unless activity is given' do
    a = Assigner.new '92345678: Foo bar foo bar'
    a.activity.should == nil
  end

  it 'should distribute multiple issue ids given' do
    a = Assigner.new '92345678: d 77 33 22 Foo bar foo bar'
    a.issue_ids.count.should == 3
    a.issue_ids.should == [77, 33, 22]
  end

  it 'should raise an exception if accessing issue_id when multiple ids are set given' do
    a = Assigner.new '92345678: d 77 33 22 Foo bar foo bar'
    a.issue_ids.count.should == 3
    expect { a.issue_id }.to raise_error(NoMethodError)
  end

  context 'when toggled from inside Redmine' do
    it 'should assign comment with feature ticket' do
      a = Assigner.new '92345678: Feature #7682 Implement toggl directly from redmine'
      a.issue_ids.first.should == 7682
      a.issue_ids.count.should == 1
    end

    it 'should assign comment with whatever ticket' do
      a = Assigner.new '92345678: Whatever #7682 Implement toggl directly from redmine'
      a.issue_ids.first.should == 7682
      a.issue_ids.count.should == 1
    end

    it 'should assign comment with unknown tracker ticket' do
      a = Assigner.new '92345678: Not a tracker #7682 Implement toggl directly from redmine'
      a.issue_ids.first.should == nil
    end

  end

  describe '#spent_on' do
    it 'assigns spent on' do
      a = Assigner.new '92345678: Foo bar foo bar : Entwicklung : Tag : 2017-04-25T09:02:30+00: 00'
      a.spent_on.should == Date.new(2017, 4, 25)
    end

    it 'does not hurt old data' do
      a = Assigner.new '92345678: Foo bar foo bar : Entwicklung'
      a.spent_on.should == nil
    end
  end
end
