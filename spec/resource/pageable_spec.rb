require './spec/spec_helper'

describe RestPack::Resource do
  describe "#paged_resource" do
    context "when paging" do
      context "with no data" do
        before(:each) do
          Song.destroy
        end

        it "should return an empty array" do
          result = Song.paged_resource()
          result.should_not == nil
          result[:songs].should_not == nil
        end
      end
      
      context "with data" do
        before(:each) do
          16.times { create(:song) }
        end
      
        it "has a valid first page" do
          result = Artist.paged_resource()
          result[:page].should == 1
          result[:total].should == 16
          result[:page_count].should == 2
          result[:previous_page].should == nil
          result[:next_page].should == 2
          result[:artists].size.should == 10
        end
      
        it "has a valid second page" do
          result = Artist.paged_resource(page: 2)
          result[:page].should == 2
          result[:previous_page].should == 1
          result[:next_page].should == nil
          result[:artists].size.should == 6
        end
      
        context "when including relations" do        
          it "should not allow invalid relations" do
            expect do
              Artist.paged_resource(:includes => 'invalid_relations')
            end.to raise_error(RestPack::Resource::InvalidInclude, "Artist.invalid_relations is not an includable relation")
          end
        
          it "should not allow includes that have not been specified with 'resource_can_include' NEW" do
            expect do
              Comment.paged_resource(:includes => 'songs')
            end.to raise_error(RestPack::Resource::InvalidInclude, "Comment.songs is not an includable relation")
          end
        
          it "should not allow a 'has_many' include when paging" do
            expect do
              Artist.paged_resource(:includes => 'songs')
            end.to raise_error(RestPack::Resource::InvalidInclude, "Artist.songs can't be included when paging artists")
          end
        
          it "should return related entities from a 'belongs_to' relationship" do
            result = Song.paged_resource(:includes => 'artists')
            result.should_not == nil
            result[:artists].should_not == nil
            result[:artists].size.should == 10
          end
        
          it "should allow multiple includes" do
            result = Song.paged_resource(:includes => 'artists,users')
            result.should_not == nil
            result[:artists].should_not == nil
            result[:artists].size.should == 10
            result[:users].size.should == 20
          end
        
          it "should return related entities with their #to_resource representation" do
            result = Song.paged_resource(:includes => 'users')
            result[:users][0][:custom].should == 'This is custom data'
          end
        
          context "when specifying overrides" do
            it "should give overrides precidence" do
              result = Artist.paged_resource({ page: 2 }, { page: 3 })
              result[:page].should == 3
            end
          end
        end
      end
    end
  end
end