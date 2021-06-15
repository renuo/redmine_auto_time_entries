require_relative 'spec_helper'
require 'date'

describe 'Assigner' do
  it 'should assign toggle id' do
    a = Assigner.new '92345678: Redmine Auto Time Entries : Entwicklung'
    expect(a.toggle_id).to eq 92345678
  end

  it 'should assign ticket 1' do
    a = Assigner.new '92345678: 741 Bla bla bla'
    expect(a.issue_ids.first).to eq 741
    expect(a.issue_ids.count).to eq 1
  end

  it 'should assign ticket 2' do
    a = Assigner.new '92345678: 742'
    expect(a.issue_ids.first).to eq 742
    expect(a.issue_ids.count).to eq 1
  end

  it 'should not assign ticket if nil' do
    a = Assigner.new '92345678: Foo bar foo bar'
    expect(a.issue_ids.first).to eq nil
  end

  it 'should assign comment without ticket' do
    a = Assigner.new '92345678: Foo bar foo bar'
    expect(a.issue_ids.first).to eq nil
    expect(a.comment).to eq 'Foo bar foo bar'
  end

  it 'should assign comment with ticket' do
    a = Assigner.new '92345678: 742 Foo bar foo bar'
    expect(a.comment).to eq 'Foo bar foo bar'
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Feature #7682 Implement toggl directly from redmine'
    expect(a.comment).to eq 'Implement toggl directly from redmine'
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Whatever #7682 Implement toggl directly from redmine'
    expect(a.comment).to eq 'Implement toggl directly from redmine'
  end

  it 'should assign comment with multiple tickets fake' do
    a = Assigner.new '92345678: 742 333 222 421 Foo bar foo bar'
    expect(a.comment).to eq '333 222 421 Foo bar foo bar'
  end

  it 'should assign comment with multiple tickets' do
    a = Assigner.new '92345678: d 742 333 222 421 Foo bar foo bar'
    expect(a.comment).to eq 'Foo bar foo bar'
  end

  it 'should assign comment with multiple tickets' do
    a = Assigner.new '92345678: d 742 333 222 421Foo bar foo bar'
    expect(a.comment).to eq '421Foo bar foo bar'
  end

  it 'should assign comment with activity 1' do
    a = Assigner.new '92345678: 742 Foo bar foo bar : Entwicklung'
    expect(a.comment).to eq 'Foo bar foo bar'
  end

  it 'should assign comment with activity 2' do
    a = Assigner.new '92345678: 742 Foo bar foo bar: something important : Entwicklung'
    expect(a.comment).to eq 'Foo bar foo bar: something important'
  end

  it 'should be valid if toggle_id is present' do
    a = Assigner.new '92345678: 742 Foo bar foo bar'
    expect(a.valid?).to eq true
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Feature #7682 Implement toggl directly from redmine'
    expect(a.valid?).to eq true
  end

  it 'should assign comment with ticket when toggled from redmine' do
    a = Assigner.new '92345678: Whatever #7682 Implement toggl directly from redmine'
    expect(a.valid?).to eq true
  end

  it 'should be invalid if toggle_id is missing 1' do
    a = Assigner.new '742 Foo bar foo bar'
    expect(a.valid?).to eq false
  end

  it 'should be invalid if toggle_id is missing 2' do
    a = Assigner.new 'Foo bar foo bar'
    expect(a.valid?).to eq false
  end

  it 'should be assignable if a ticket id can be found' do
    a = Assigner.new '92345678: 777 Foo bar foo bar'
    expect(a.assignable?).to eq true
  end

  it 'should not be assignable if a ticket id cannot be found' do
    a = Assigner.new '92345678: Foo bar foo bar'
    expect(a.assignable?).to eq false
  end

  it 'should filter an activity' do
    a = Assigner.new '92345678: Foo bar foo bar : Entwicklung'
    expect(a.activity).to eq 'Entwicklung'
  end

  it 'should filter an activity with complicated comment' do
    a = Assigner.new '92345678: Foo bar foo bar : something important : Entwicklung'
    expect(a.activity).to eq 'Entwicklung'
  end

  it 'should leave activity empty unless activity is given' do
    a = Assigner.new '92345678: Foo bar foo bar'
    expect(a.activity).to eq nil
  end

  it 'should distribute multiple issue ids given' do
    a = Assigner.new '92345678: d 77 33 22 Foo bar foo bar'
    expect(a.issue_ids.count).to eq 3
    expect(a.issue_ids).to eq [77, 33, 22]
  end

  it 'should raise an exception if accessing issue_id when multiple ids are set given' do
    a = Assigner.new '92345678: d 77 33 22 Foo bar foo bar'
    expect(a.issue_ids.count).to eq 3
    expect { a.issue_id }.to raise_error(NoMethodError)
  end

  context 'when toggled from inside Redmine' do
    it 'should assign comment with feature ticket' do
      a = Assigner.new '92345678: Feature #7682 Implement toggl directly from redmine'
      expect(a.issue_ids.first).to eq 7682
      expect(a.issue_ids.count).to eq 1
    end

    it 'should assign comment with whatever ticket' do
      a = Assigner.new '92345678: Whatever #7682 Implement toggl directly from redmine'
      expect(a.issue_ids.first).to eq 7682
      expect(a.issue_ids.count).to eq 1
    end

    it 'should assign comment with unknown tracker ticket' do
      a = Assigner.new '92345678: Not a tracker #7682 Implement toggl directly from redmine'
      expect(a.issue_ids.first).to eq nil
    end

  end

  describe '#spent_on' do
    it 'assigns spent on' do
      a = Assigner.new '92345678: Foo bar foo bar : Entwicklung : Tag : 2017-04-25T09:02:30+00: 00'
      expect(a.spent_on).to eq Date.new(2017, 4, 25)
    end

    it 'does not hurt old data' do
      a = Assigner.new '92345678: Foo bar foo bar : Entwicklung'
      expect(a.spent_on).to eq nil
    end
  end
end
