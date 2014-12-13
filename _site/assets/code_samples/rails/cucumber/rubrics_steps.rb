Given /^I have a rubric$/ do
  my.rubric = repository.rubric
end

Given /^I have a locked rubric$/ do
  my.rubric = repository.rubric
  my.rubric_components << repository.rubric_component
  my.rubric_components << repository.rubric_component

  my.course = repository.course
  my.question = repository.question(type: :essay, rubric: my.rubric)
  my.assessment_template = repository.assessment_template
  my.assessment = repository.assessment
  my.assessment_template_question = repository.assessment_template_question

  repository.assessment_response repository.student
  my.assessment_template_question.reload

  my.rubric.reload.should be_locked
end

Given /^I have a rubric with components$/ do
  my.rubric = repository.rubric
  my.rubric_components << repository.rubric_component(weight: 50)
  my.rubric_components << repository.rubric_component(weight: 50)
end

Then /^I should not be able to edit the rubric components$/ do
  page.should have_css('.app-add-component.disabled')
  page.has_css?(".app-edit-component", visible: true).should be_false
end

When /^I view the rubrics$/ do
  view_rubrics
end

Then /^I should see my rubric$/ do
  page.should have_css('.app-rubric', text: my.rubric.title)
end

When /^I edit my rubric$/ do
  view_rubrics
  edit_rubric(my.rubric)
end

When /^I delete my rubric$/ do
  delete_rubric
end

Then /^I should see my rubric has been deleted$/ do
  page.should have_content('Rubrics')

  Rubric.find_by_id(my.rubric.id).should_not be
end


When /^I change the rubric title to #{S}$/ do |title|
  within('.app-rubric') do
    fill_in 'rubric_title', with: title
    page.find('.app-save-rubric').click
  end
  
  wait_for_ajax_completion
  my.rubric.reload
end

Then /^I should see #{S} as the rubric title$/ do |title|
  my.rubric.reload.title.should == title
  refresh
  page.should have_css('.app-rubric', text: my.rubric.title)
end

When /^I update my component weights$/ do
  click_css('.app-distribute-weight .app-no')

  within('.component:first-child') do
    fill_in 'rubric[rubric_components_attributes][][weight]', with: 60
  end

  within('.component:last-child') do
    fill_in 'rubric[rubric_components_attributes][][weight]', with: 40
  end

  page.find('.app-save-rubric').click
  wait_for_ajax_completion
end

When /^I should see my new weights on the given components$/ do
  my.rubric.reload.rubric_components.first.weight.to_i.should == 60
  my.rubric.reload.rubric_components.last.weight.to_i.should == 40
end

When /^I evenly distribute my component weights$/ do
  click_css('.app-distribute-weight .app-yes')
  page.find('.app-save-rubric').click

  wait_for_ajax_completion
end

When /^I should see my component weighted equally$/ do
  my.rubric.reload.rubric_components.first.weight.to_i.should == 50
  my.rubric.reload.rubric_components.last.weight.to_i.should == 50
end

Then /^I should see the rubric components$/ do
  component = my.rubric_components.each do |component|
    within('.app-rubric-component', text: component.indicator) do
      page.find('.app-component-toggle').click()
      wait_until(2) { has_css?(".accordion-body.in") }
      sleep(1)
      page.should have_css('.app-weight', value: "50")
      component.rubric_component_descriptors.each do |descriptor|
        page.should have_css('.descriptor .body', text: descriptor.body)
      end
    end
  end
end

Given /^I am creating a rubric component$/ do
  my.rubric = repository.rubric
  view_rubrics
  edit_rubric(my.rubric)
  create_component
end

Then /^I add a rubric component indicator$/ do
  fill_in 'indicator', with: "Knows how to write stuff good"
  step %(I fill in "rubric_component_nonfulfillment_descriptor" with "Nope!" using rich text)
end


Then /^I add 5 descriptors$/ do
  page.find('.app-add-descriptor').click
  page.find('.app-add-descriptor').click
  page.find('.app-add-descriptor').click

  5.times do |i|
    within ".descriptor:nth-child(#{i+1})" do
      step %(I fill in "short_description" with "descriptor short text #{i+1}")
      body = page.find('.body')
      step %(I fill in "#{body[:id]}" with "descriptor text #{i+1}" using rich text)
      body.trigger('blur')
    end
  end
end

Then /^I save the component$/ do
  find('.app-save-component').click

  wait_until(4) do
    has_css?(".app-components .app-rubric-component")
  end

  my.rubric.reload
end

Then /^I should see my rubric has a new component indicator$/ do
  my.rubric.rubric_components.size.should == 1
  my.rubric.rubric_components.first.indicator.should == "Knows how to write stuff good"
end

When /^I edit my new rubric component$/ do
  find('.app-edit-component').click
end

Then /^I should see my component indicator$/ do
  find('.app-indicator').value.should == "Knows how to write stuff good"
end

And /^I should see my component nonfulfillment descriptor$/ do
  find('.app-nonfulfillment-descriptor').value.should == "<p>Nope!</p>"
end

And /^I should see my 6 descriptors$/ do
  6.times do |i|
    get_wysiwyg_content("app-descriptor-#{i}").should == "<p>descriptor text #{i}</p>"
  end
end

Given /^I add descriptor (\d+) as "([^"]*)"$/ do |idx, text|
  step %(I fill in "app-descriptor-#{idx}" with "#{text}" using rich text)
end

When /^I clear descriptor (\d+)$/ do |idx|
  within ".descriptor-l#{idx}" do
    find(".app-clear").click
  end
end

Then /^descriptor (\d+) should be "([^"]*)"$/ do |idx, val|
  get_wysiwyg_content("app-descriptor-#{idx}").should == val
end

Then /^I give the component a weight$/ do
  select '4', from: 'rubric-weight'
end

And /^I should see my component weight$/ do
  find('#rubric-weight').value.should == "4"
end


When /^I add a new rubric$/ do
  create_rubric

  my.rubric = Rubric.first

  within('.app-rubric') do
    fill_in 'rubric_title', with: "Some title"
    page.find('.app-save-rubric').click
  end
  
  wait_for_ajax_completion

  my.rubric.reload
end

