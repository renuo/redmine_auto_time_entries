require_relative 'spec_helper'

describe 'Assigner' do
  it 'should assign toggle id' do
    a = Assigner.new '92345678: Redmine Auto Time Entries : Entwicklung'
    a.toggle_id.should == 92345678
  end

  it 'should assign ticket 1' do
    a = Assigner.new '92345678: 741 Bla bla bla'
    a.ticket_id.should == 741
  end

  it 'should assign ticket 2' do
    a = Assigner.new '92345678: 742'
    a.ticket_id.should == 742
  end

  it 'should not assign ticket if nil' do
    a = Assigner.new '92345678: Foo bar foo bar'
    a.ticket_id.should == nil
  end

  it 'should assign comment without ticket' do
    a = Assigner.new '92345678: Foo bar foo bar'
    a.ticket_id.should == nil
    a.comment.should == 'Foo bar foo bar'
  end

  it 'should assign comment with ticket' do
    a = Assigner.new '92345678: 742 Foo bar foo bar'
    a.comment.should == 'Foo bar foo bar'
  end

  it 'should be valid if toggle_id is present' do
    a = Assigner.new '92345678: 742 Foo bar foo bar'
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
end