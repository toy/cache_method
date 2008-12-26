require File.dirname(__FILE__) + '/spec_helper'

class Person
  include CacheMethod
  def read_attribute(name)
    (@attributes ||= {})[name.to_s]
  end
  def write_attribute(name, value)
    (@attributes ||= {})[name.to_s] = value
  end
  def uniq_value
    rand
  end
  cache_method :uniq_value
end

describe CacheMethod do
  before :each do
    @uniq_value = rand
    @person = Person.new
    @person.stub!(:new_record?).and_return(false)
    @person.stub!(:save).and_return(true)
  end

  it "should call calculate for the first time" do
    @person.should_receive(:calculate_uniq_value).once.and_return(@uniq_value)
    @person.uniq_value
  end

  it "should not call calculate if value is cached" do
    @person.write_attribute(:uniq_value, @uniq_value)
    @person.should_not_receive(:calculate_uniq_value)
    @person.uniq_value
  end

  it "should call calculate only once for multiple calls" do
    @person.should_receive(:calculate_uniq_value).once.and_return(@uniq_value)
    @person.uniq_value
    @person.uniq_value
  end

  it "should return same for multiple calls" do
    @person.uniq_value.should == @person.uniq_value
  end

  it "should call calculate twice for update" do
    @person.should_receive(:calculate_uniq_value).twice
    @person.uniq_value
    @person.update_uniq_value
  end

  it "should call calculate twice for reset" do
    @person.should_receive(:calculate_uniq_value).twice
    @person.uniq_value
    @person.reset_uniq_value
    @person.uniq_value
  end

  it "should call save with saved record" do
    @person.should_receive(:save)
    @person.uniq_value
  end

  it "should not call save with new record" do
    @person.stub!(:new_record?).and_return(true)
    @person.should_not_receive(:save)
    @person.uniq_value
  end
end
