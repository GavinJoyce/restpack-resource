require './spec/spec_helper'

describe RestPack::Resource do
  describe "#resource_paged_resource" do    
    context "when sorting" do
      context "with invalid options" do
        it "should not allow invalid sort column" do
          expect do
            Artist.resource_paged_resource(:sort_by => :invalid_column)
          end.to raise_error(RestPack::Resource::InvalidSortBy)
        end
      end
    end
  end
end