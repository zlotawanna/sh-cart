require 'rails_helper'

RSpec.describe 'recipes/edit', type: :view do
  before(:each) do
    @recipe = assign(:recipe, Recipe.create!(
                                name: 'MyString',
                                description: 'MyText'
                              ))
  end

  it 'renders the edit recipe form' do
    render

    assert_select 'form[action=?][method=?]', recipe_path(@recipe), 'post' do
      assert_select 'input[name=?]', 'recipe[name]'

      assert_select 'textarea[name=?]', 'recipe[description]'
    end
  end
end
