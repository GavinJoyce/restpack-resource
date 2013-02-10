require './spec/spec_helper'

describe RestPack::Resource do
  describe "#paged_resource" do    
    context "when sorting" do
      context "with invalid options" do
        it "should not allow invalid sort column" do
          expect do
            Artist.paged_resource(:sort_by => :invalid_column)
          end.to raise_error(RestPack::Resource::InvalidSortBy)
        end
      end
      
      context "with valid options" do
        before(:each) do
          20.times { create(:artist) }
        end
        
        it "should default to ascending" do
          result = Artist.paged_resource(:sort_by => :id)
          result[:count].should == Artist.count
          result[:artists].first[:id].should == 1
          result[:artists].last[:id].should == 10
        end

        it "should allow sort_direction of descending" do
          result = Artist.paged_resource(:sort_by => :id, :sort_direction => :descending)
          result[:count].should == Artist.count
          result[:artists].first[:id].should == 20
          result[:artists].last[:id].should == 11
        end

        it "should allow sort_by and sort_direction to be string or symbol" do
          result = Artist.paged_resource(:sort_by => 'id', :sort_direction => 'descending')
          result[:count].should == Artist.count
          result = Artist.paged_resource(:sort_by => :id, :sort_direction => :descending)
          result[:count].should == Artist.count
        end
      end
    end
  end
end