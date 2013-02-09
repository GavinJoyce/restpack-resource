require './spec/spec_helper'
require './lib/restpack-resource'

describe RestPack::Resource do
  describe "#resource_paged_resource" do 
    context "when filtering" do
      context "with invalid options" do
        it "should not allow invalid filters" do
          expect do
            Artist.resource_paged_resource(:filters => {:this_is_invalid => 4})
          end.to raise_error(RestPack::Resource::InvalidFilter)
        end
      end
      
      context "with valid options" do
        before(:each) do
          @artist = FactoryGirl.create(:artist)
          3.times { FactoryGirl.create(:song, artist: @artist) }
          12.times { FactoryGirl.create(:song) }
        end
        
        it "should return the total count" do
          result = Song.resource_paged_resource()
          result[:total].should == 15
        end
        
        it "should filter results" do          
          result = Song.resource_paged_resource(:filters => {:artist_id => @artist.id})
          result[:total].should == 3
        end
      end
    end
  end
end