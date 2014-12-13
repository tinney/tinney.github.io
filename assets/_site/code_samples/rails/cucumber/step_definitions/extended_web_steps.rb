module RailsViewHelpers
  @@container = class WrappedClass
    include(ActionView::Helpers::SanitizeHelper)
    include(ActionView::Helpers::JavaScriptHelper)
  end.new

  def view_helper
    @@container
  end
end

World(RailsViewHelpers)

Given /^I view the page$/ do
  save_and_open_page
end

Given /^I screenshot the page$/ do
  screenshot_and_open_image
end

Given /^I follow the reports navigation$/ do
  page.find('.nav-reports').click
end

Then /^I should be on the reports page$/ do
  page.should have_css('#reports-new')
end

Given /^I pry$/ do
  binding.remote_pry
end

Given /^I look at the page$/ do
  save_and_open_page
end

Given /^I (?:login|log back in)$/ do
  login_as(my.user)
end

Given /^I am an? (administrator|proctor|educator) named #{S}$/ do |user_type, first_name|
  my.organization = repository.organization
  my.user = repository.send(user_type.to_sym, first_name: first_name)
end

Given /^I am an? (student|administrator|proctor|educator|creator|building administrator|organization administrator)$/ do |user_type|
  my.organization = repository.organization
  my.user = repository.send(user_type.gsub(' ','_').to_sym)
  my.school = repository.school
  repository.add_user_to_school
end

Given /^their organization is named #{S}$/ do |name|
  their.organization = repository.organization(title: name)
end

Given /^I am an educator with the course #{S}$/ do |course_name|
  my.organization = repository.organization
  my.user = repository.proctor
  my.school = repository.school
  my.course = repository.course(title: course_name)
end

Given /^I have the course #{S}$/ do |course_name|
  my.course = repository.course(title: course_name)
end

Given /^there exists a (proctor|creator) with (?:the |)courses:$/ do |role, rows| 
  step %(I am a #{role} with the courses:), rows
end

Given /^I am a (proctor|creator) with the courses:$/ do |role, rows| 
  my.organization = repository.organization
  my.school = repository.school
  my.user = repository.send role.to_sym

  rows.raw.each_with_index do |row, index|
    my.courses << repository.course(title: row.first)
  end

  my.course = my.user.courses.first
end

Given /^I am a (proctor|creator) with a course$/ do |role| 
  my.organization = repository.organization
  my.school = repository.school
  my.user = repository.send(role.to_sym)
  my.course = repository.course
end

Given /^I am a(?:n|) (proctor|educator|creator) with a course named #{S}$/ do |role, course_title|
  my.organization = repository.organization
  my.user = repository.send(role.to_sym)
  my.school = repository.school
  my.course = repository.course(title: course_title)
end

Given /^I am a program administrator( for the organization|)$/ do |in_org|
  if in_org.present?
    my.user = repository.program_administrator(organization: my.organization)
  else
    my.organization = repository.organization
    my.user = repository.program_administrator
  end

  my.program = repository.program
end


Given /^my organization is named #{S}$/ do |org_name|
  my.organization.title = org_name
  my.organization.save!
end

Given /^my program is named #{S}$/ do |program_name|
  my.program.title = program_name
  my.program.save!
end

Given /^I login as an administrator$/ do
  my.organization = repository.organization
  my.user = repository.administrator
  login_as(my.user)
end

Given /^I am also a(?:n|) (\w*)/ do |role|
  my.user.add_role(role.to_sym)
end

Given /^I do have the creator (?:ability|role)$/ do
  my.user.add_role(:creator)
end

Given /^I have created an assessment template$/ do
  repository.create_and_set_happy_day
end

Given /^My assessment template has the questions:$/ do |rows|
  rows.raw.each_with_index do |row, index|
    question = Question.find_by_title(row.first)
    question.should be
    Fabricate :assessment_template_question, :question => question, :points => row.second, :position => index, :assessment_template => my.assessment_template
  end
end

Given /^I have an unassigned assessment(?: template|)$/ do
  repository.create_naked_template
end

Given /^I have an unassigned assessment(?: template|) named #{S}$/ do |assessment_template_title|
  my.assessment_template = repository.assessment_template(:title => assessment_template_title)
end

Given %r{^I have created an assessment(?: for that course|)$} do
  repository.create_and_set_happy_day title: "Assessment #1"
  repository.add_question_to_assessment_template
end

Given /^that course has an assessment$/ do
  steps %(Given I have created an assessment)
end

Given %r{^a student takes (?:my|the) assessment$} do
  student = repository.student
  my.students << student
  my.course.reload
  repository.students_take_assessment(students: [student])
end

When /^I delete the answer #{S}$/ do |answer_body|
  handle_js_confirm(true) do
    within('.answer-item', :text => answer_body) do
      id = page.has_css?('.delete-button') ? '.delete-button' : '.delete-button-blank' 
      find(id).click
    end
  end
end

When /^(.*) and (unconfirm|confirm) the confirmation dialog$/ do |my_step, confirm|
  handle_js_confirm(confirm == "confirm") { step my_step }
end

Given /^I save the assessment template$/ do
  save_assessment_template
end

Given %r{^I edit my assessment template$} do
  login_as(my.user)
  edit_assessment_template(my.assessment_template)
  wait_for_mce
end

Given %r{^I edit the question #{S}$} do |question|
  login_as(my.user)
  edit_question(question)
  wait_for_mce
end

Given %r{^I delete the assessment template$} do
  open_assessment_template_options()
  step %(I follow "Delete")
end

Given /^I should no longer see my assessment template$/ do
  view_assessment_templates
  step %(I should not see "#{my.assessment_template.title}")
end

Given /^I should see my assessment template$/ do
  view_assessment_templates
  step %(I should see my assessment template on the page)
end

Given /^I should (not |)see my assessment template on the page/ do |not_see|
  step %(I should #{not_see}see "#{my.assessment_template.title}") 
end

Given %r{^I view the students results$} do
  login_as(my.user)
  step %{PENDING for access to courses}
  view_assessment_response(my.students[0].assessment_responses.first)
end

Given %r{^I view my assessment$} do
  view_assessment(my.assessment)
end

Given %r{^I save the item$} do 
  step %{I follow "Save & Finish"}
end

Given %r{^I submit the answers} do
  click_css("#new-answer-button")
  wait_for_ajax_completion
end

Then /^the answer should be selected$/ do
  page.should have_css(".answer.active")
end

Given %r{I upload the file for (question|answer body|answer match) with the attributes:} do |upload_type, attributes|
  case upload_type
  when "question"
    selector = ".upload-question-media-button"
  when "answer body"
    selector = "#answer-body-media-upload"
  when "answer match"
    selector = "#answer-match-media-upload"
  else 
    raise Exception.new "Unknown upload type passed in: #{upload_type}"
  end

  step %(I click the element "#{selector}")
  sleep(2)

  attributes.raw.each do |row|
    name = row.first
    value = row.second

    if name == "file_name" 
      path = File.join(::Rails.root, "features/fixtures/", value) 
      attach_file("media_asset[file]", path)
    else
      step %(I fill in "media_asset[#{name}]" with "#{value}")
    end
  end

  step %(I click the element "#media-form-submit-button")
end

When /^I wait "([^"]*)"$/ do |seconds|
  steps %(And I wait #{seconds} seconds)
end

When /^I (?:sleep|wait) (\d+)(?: seconds|)$/ do |seconds|
  sleep(seconds.to_i)
end

When /^I ask #{S}$/ do |prompt|
  ask prompt
end

When /^(?:|I )click the element "([^"]*)"$/ do |selector|
  find(selector).click
end

And /^there should be "([^"]+)" answers$/ do |num_answers_param|
  wait_for_ajax_completion
  num_answers = num_answers_param.to_i
  all('#answers li').length.should == num_answers 
end

And /^the answer "([^"]+)" should be (incorrect|correct)$/ do |answer, correct|
  page.should have_css(".answer-item.#{correct}", :text => answer)
end

And /^I view the selected questions$/ do
  find('.app-preview').click
end

And /^I fill in points with "([^"]+)" for the question "([^"]+)"$/ do |points, question_title|
  step %(I fill in "points" with "#{points}" within "#assessment-template-questions-expand :contains('#{question_title}')")
  find("#assessment-template-questions-expand :contains('#{question_title}') .save-button").click
   
  wait_for_ajax_completion
end

def wait_for_ajax_completion
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

And /^the assessment template question "([^"]+)" should have the points "([^"]+)"$/ do |question_title, points|
  step %(the "points" field should contain "#{points}" within "#assessment-template-questions-expand :contains('#{question_title}')")
end

And /^I select the question "([^"]+)"$/ do |question_title|
  within('.item', :text => question_title) do
    find('div', :text => question_title).click
  end
end

Given /^PENDING/ do
  pending
end


Then /^I should (not )?see the uploaded image "([^"]+)" for (answer|question|assessment question)$/ do |not_have_image, image_src, question_type|
  if question_type == "question"
    selector = ".app-question"
  elsif question_type == "assessment question" 
    selector = ".question-content"
  elsif question_type == "answer"
    selector = ".answers"
  end

  within (selector) do
    if not_have_image.blank?
      page.should have_css("img[src$='#{image_src}']") 
    else
      page.should_not have_css("img[src$='#{image_src}']") 
    end
  end
end

And /^I refresh the page$/ do
  refresh
end

Then /^I should see question with the title of "([^"]+)"$/ do |title|
  find('#question_title').value.should == title
end

Then /^I should see question with the description of "([^"]+)"$/ do |description|
  find('#question_description').value.should include(description)
end


And /^I lose focus on "([^"]+)"$/ do |selector|
  trigger_blur_on(selector)
end

When /^I click the standard with text "([^"]+)"$/ do |text|
  find('.standard', :text => text, visible: true).click
end

When /^I click the recent standard with text "([^"]+)"$/ do |text|
  find('.app-recent-classifications .classification', :text => text).click
end

And /^I change assessment template attributes to the following:$/ do |rows|
  rows.raw.each do |row|
    case row.first
    when 'title'
      fill_in('assessment_title', :with => row.second)
    when 'instructions'
      fill_in_wysiwyg_content(row.second)
    else
      raise Exception.new("Unsupported assessment template attribute: #{row.first}")
    end
  end

  save_assessment_template
end

When /^I award "([^"]+)" points the response to "([^"]+)"$/ do |points, question_title|
  within('.response', :text => question_title) do
    fill_in "awarded_points", :with => points
    find('.save-button').click
  end
end

Then /^I should see the response to "([^"]+)" with "([^"]+)" awarded points$/ do |question_title, awarded_points|
  page.should have_css('.app-response', :text => question_title)  
  within('.app-response', :text => question_title) do
    page.should have_css("input[name='awarded_points'][value='#{awarded_points}']")
  end  
end

Then /^I should see the response to "([^"]+)" with "([^"]+)" awarded points and with answers:$/ do |question_title, awarded_points, rows|
  step %(I should see the response to "#{question_title}" with "#{awarded_points}" awarded points)
  within('.app-response', :text => question_title) do
    for row in rows.raw do
      answer_body = row.first
      answer_selector = ".answer.#{row.second.gsub(" ", ".")}"
      page.should have_css(answer_selector, :text => answer_body)
    end
  end
end

Then /^I should see the following matches for matching question "([^"]+)":$/ do |question_title, rows|
  within('.matching-question', :text => question_title) do
    answer_nodes = all('.answer')
    rows.raw.each do |row|
      body = row.first
      match = row.second
      answer_css_class = row.third

      answer_node = answer_nodes.detect do |node| 
        node.has_selector?(".body", :text => body) && node.has_selector?(".match", :text => match)
      end
      answer_node.should be
      answer_node[:class].should include(answer_css_class)
    end
  end
end

def answer_selector(answer_css)
  (answer_css.split(" ") << 'answer').inject("") { |accum, str| "#{accum}.#{str}" }
end

Given /^I start to take "([^"]+)" for "([^"]+)"$/ do |assessment_title, course_title|
  student_view_course(course_title)
  start_assessment(assessment_title)
end

When /^I resume taking the assessment$/ do
  resume_assessment(my.assessment.title, my.course.title, :begin => :sequential)
end

Given /^I should see "([^"]+)" marked as done$/ do |assessment_title|
  within('.app-completed-assessments .app-assessment', :text => assessment_title) do
    step %(I should see "Completed")
  end
end

Given /^I take #{S} for #{S}$/ do |assessment_title, course_title|
  step %(I start to take "#{assessment_title}" for "#{course_title}")
  step %(I finish reading the instructions and start the assessment)
  turn_in_assessment
end

Given /^I should see "([^"]+)" as a (completed )assessment$/ do |assessment_title, status|
  if status == "completed"
    within("table", :text => "Completed Assessments") do
      page.should have_css('.assessmenet', :text => assessment_title)
    end
  end
end

def choose_response_for(question_type, response)
  case(question_type)
    when /multiple choice/
      if Answer.find_by_body(response).present?
        answer_body = response
        find(".answer", :text => answer_body).click
      else
        image_filename = response
        find("img[src$='#{image_filename}']").click
      end
    when /true\/false/
      answer_body = response
      find(".answer", :text => answer_body).click
    when /essay/, /short answer/
      answer_body = response
      fill_in('answer', :with => response)
      step %(I lose focus on ".answer") # to force saving to database
  end

  wait_for_ajax_completion
end

When /^I put in the following responses for each question:$/ do |rows|
  rows.raw.each do |row|
    question_description = row.first
    question_type = row.second
    response = row.third

    within(".question", :text => question_description) do
      choose_response_for question_type, response
    end
    if has_css?('.app-next-question')
      find('.app-next-question').click 
      wait_for_ajax_completion
    end
  end
end

Then /^the multiple choice response "([^"]+)" should have the following images as the answers:$/ do |question_title, rows|
  question = Question.find_by_title question_title
  question.should be
  
  within("tbody#question-#{question.id}") do
    rows.raw.each do |row|
      image_filename = row.first
      chosen = row.second

      answer = page.find(".answers .answer")
      answer[:class].should include "chosen" if chosen == "chosen"

      page.should have_selector("img[src$='#{image_filename}']")
    end
  end
end

Then /^the matching response "([^"]+)" should have the following images as the answers:$/ do |question_title, rows|
  question = Question.find_by_title question_title
  question.should be

  within("tbody#question-#{question.id}") do
    rows.raw.each do |row|
      choice_filename = row.first
      match_filename = row.second

      page.should have_selector(".answer .body img[src$='#{choice_filename}']")
      page.should have_selector(".answer .match img[src$='#{match_filename}']")
    end
  end
end

Given /^I put in the following responses for matching question "([^"]+)":$/ do |question_description, rows|
  def click_the_answer_for(args)
    type = args[:type]
    value = args[:value]

    column_name = type == "choices" ? "body" : "match"

    if Answer.where("`#{column_name}` = '#{value}'").first.present?
      answer_text = value
      find(".#{type} .answer", :text => answer_text).click
    else
      filename = value
      page.find(".#{type} .answer .media-asset img[src$='#{filename}']").click
    end
  end

  within(".question", :text => question_description) do
    for row in rows.raw do
      click_the_answer_for :type => 'choices', :value => row.first
      click_the_answer_for :type => 'matches', :value => row.second
    end
  end
end

Then /^I take "([^"]+)" for "([^"]+)" with matching question "([^"]+)" responses:$/ do |assessment_title, course_title, question_description, rows|
  step %(I start to take "#{assessment_title}" for "#{course_title}")
  step %(I finish reading the instructions and start the assessment)
  step %(I put in the following responses for matching question "#{question_description}":), rows
end

Then /^I take "([^"]+)" for "([^"]+)" with the following responses:$/ do |assessment_title, course_title, rows|
  step %(I start to take "#{assessment_title}" for "#{course_title}")
  step %(I finish reading the instructions and start the assessment)
  step %(I put in the following responses for each question:), rows
  
  turn_in_assessment
end


def first_course_with(title)
  course_node = find(".course", :text => title)
  course_node.should_not be_nil
  course_node
end

def first_assessment_schedule_with(course_node, title)
  course_node.find('.assessment', :text => title)
end

def first_answer_with(question_node, answer_body)
  question_node.all('.answer').detect { |node| node.find('.body').text == answer_body }
end

def first_assessment
  all('.assessment').first
end

def first_question_with(description)
  first(".question:contains('#{description}')")
end

def assessment_schedule(options)
  course_node = first_course_with(options[:course_title])
  first_assessment_schedule_with(course_node, options[:assessment_title])
    .find('a', :text => options[:text])
end

Then /^I should see assessment "([^"]+)"$/ do |assessment_title|
  page.should have_css('.app-assessment-template', :text => assessment_title)
end

When /^I grade the assessment "([^"]+)" for "([^"]+)" by "([^"]+)"$/ do |assessment_title, course_title, student_name|
  step %(I view the assessments for "#{assessment_title}" for course "#{course_title}")
  view_student_overview_tab
  step %(I follow "#{student_name}")
end

Then /^the assessment template instructions should be "([^"]+)"$/ do |assessment_instructions|
  get_wysiwyg_content.should =~ /#{assessment_instructions}/
end

Then /^I should see questions in the following order in the preview:$/ do |rows|
  preview_assessment_template
  rows.raw.each_with_index do |row, index|
    page.should have_css("#questions .question:nth-child(#{index+1})", text: row.first)
  end
end

Then /^I should see answers in the following order in the preview:$/ do |rows|
  rows.raw.each_with_index do |row, index|
    answer_body = row.first
    find("#question-preview .answers li:nth-child(#{index+1}) .body").text.should == answer_body
  end
end

Then /^I should see answers in the following order:$/ do |rows|
  rows.raw.each_with_index do |row, index|
    answer_body = row.first
    find("#answers li:nth-child(#{index+1}) .body").text.should == answer_body
  end
end

Then /^I should see answers for "([^"]+)" in the following order in the assessment:$/ do |question_description, rows|
  within('.question', :text => question_description) do 
    rows.raw.each_with_index do |row, index|
      answer_body = row.first
      find(".answers li:nth-child(#{index+1}) .body").text.include?(answer_body).should be_true
    end
  end
end

Then /^I should see the following answers for multiple choice question "([^"]+)":$/ do |question_title, rows|
  within('.multiple-choice-question', :text => question_title) do
    rows.raw.each do |row|
      answer_body = row.first
      answer_css_class = row.second.gsub(" ", ".")

      page.should have_css(".answer.#{answer_css_class}:contains('#{answer_body}')")
    end
  end
end

def drag_js_included?
  page.evaluate_script "window.simulate_js_included"
end

def include_drag_js_if_needed
  unless drag_js_included?
    page.execute_script "#{File.read(Rails.root.join("spec","javascripts", "support", "jquery.simulate.js"))};window.simulate_js_included = true;"
  end
end

def drag_sorted_element(selector, answer_body, direction, height_multiplier)
  include_drag_js_if_needed
  drag_direction = direction.to_sym == :up ? -1 : 1

  page.execute_script <<-EOS
    var offsetDiff = $("#{selector}:nth-child(2)").offset().top - $("#{selector}:nth-child(1)").offset().top;

    var dragDistance = #{drag_direction}*(#{height_multiplier}*offsetDiff+1);

    var drag = $("#{selector}:contains('#{answer_body}')"); 
    drag.simulate("drag", {dy:dragDistance});
  EOS

  sleep 1 # ouchie
  wait_for_ajax_completion
end

When /^I drag answer "([^"]+)" "([^"]+)" "([^"]+)" rows$/ do |answer_body, direction, num_rows|
 drag_sorted_element("#answers .answer-item", answer_body, direction, num_rows)
end

When /^I drag assessment template question "([^"]+)" "([^"]+)" "([^"]+)" rows$/ do |title, direction, num_rows|
  drag_sorted_element("#app-assessment-template-questions .app-question-row", title, direction, num_rows)
end

Given /^I start creating a (Short Answer|Matching|Essay|Multiple Choice|True\/False) Question$/ do |question_type|
  step %(I go to the questions page)
  step %(I follow "#{question_type}")
  wait_for_mce
end

Given /^I delete the classification "([^"]+)"$/ do |classification|
  step "I align a standard"
  handle_js_confirm(true) do
    within('#classification-modal .classification', :text => classification) do
      find("a.delete-button").click
    end
  end
end

Given /^I logout$/ do
  logout
end

def find_assessment(assessment_template_title, course_title)
  course = Course.find_by_title(course_title)
  assessment_template = AssessmentTemplate.find_by_title(assessment_template_title)
  Assessment.find_by_course_id_and_assessment_template_id(course.id, assessment_template.id)
end

And /^I view the assessments for "([^"]+)" for course "([^"]+)"$/ do |assessment_template_title, course_title|
  assessment = find_assessment(assessment_template_title, course_title)
  view_assessment(assessment)
end

And /^I view the assessment overview for "([^"]+)" for course "([^"]+)"$/ do |assessment_template_title, course_title|
  assessment = find_assessment(assessment_template_title, course_title)
  view_assessment(assessment)
  view_assessment_overview_tab
end

And /^I edit the assessments for "([^"]+)"$/ do |assessment_template_title|
  within('.app-assessment-template', :text => assessment_template_title) do
    step %(I follow "Edit")
    wait_for_mce
  end
end

When /^I delete media "([^"]+)"$/ do |media_asset_title|
  handle_js_confirm(true) do
    within('.media-asset', :text => media_asset_title) do
      find('.btn.delete').click
    end
  end
end

And /^the assessment "([^"]+)" for course "([^"]+)" opens at "([^"]+)" and closes at "([^"]+)"$/ do |assessment_title, course_title, opens_at, closes_at|
  assessment_template = AssessmentTemplate.find_by_title(assessment_title)
  assessment_template.should be
  course = Course.find_by_title(course_title)
  course.should be
  assessment = Assessment.find_by_assessment_template_id_and_course_id(assessment_template.id, course.id)
  assessment.should be

  close_date = DateTime.parse("#{closes_at} #{DateTime.now.zone}")
  open_date = DateTime.parse("#{opens_at} #{DateTime.now.zone}")

  assessment.update_attributes!(:opens_at => open_date, :closes_at => close_date)
end

Given /^the current datetime is "([^"]+)"$/ do |datetime|
  DateTime.stub(:now).and_return(DateTime.parse(datetime))
end

Then /^I should see the assessment on my dashboard assigned to my course$/ do
  steps %(And I go to the dashboard)

  within('.app-course', text: my.course.title) do
    page.should have_css('.app-assessment', text: my.assessment_template.title)
  end
end

Then /^I should see "([^"]+)" as takable assessment for "([^"]+)"$/ do |assessment_title, course_title|
  student_view_course(course_title)

  within('.app-assessment', text: assessment_title) do
    page.should have_css('.app-action', value: 'Start')
  end
end

Then /^I should not see "([^"]+)" as takable assessment for "([^"]+)"$/ do |assessment_title, course_title|
  within(".app-course", text: course_title) do
    page.should_not have_css('.app-assessment', text: assessment_title)
  end
end

Then /^I should see "([^"]+)" was completed at "([^"]+)"$/ do |assessment_title, completed_at|
  within('.assessment', :text => assessment_title) do
    page.should have_css('.completed-at', :text => completed_at)
  end
end


When /^I toggle the answer (True|False)$/ do |answer_body|
  within('.answer-item', :text => answer_body) do
    find('.answer-toggle').click 
  end
end

Then /^I should see (True|False) marked as (correct|incorrect)$/ do |answer_body, correct_choice|
  step %(the answer "#{answer_body}" should be #{correct_choice})
end

When /^I click add new answer button$/ do
  step %(I click the element "#new-answer-button")
end

Then /^I should see "([^"]+)" as one of the answer (body|match) media assets$/ do |filename, answer_type|
  selector = answer_type == 'body' ? '#answer-body-media-assets' : '#answer-match-media-assets'

  page.should have_css("#{selector} img[src$='#{filename}']")
end

Then /^I should see the image "([^"]+)" in one of the answers$/ do |image_filename|
  page.should have_selector("#answers .answer-item img[src$='#{image_filename}']")
end


Then /^I should see "([^"]+)" total questions$/ do |total|
  page.should have_css(".app-preview .total-questions .count", :text => total)
end

Then /^I should see "([^"]+)" total points$/ do |total|
  page.should have_css(".total-points .count", :text => total)
end

Then /^I should see the following question count under assessment overview:$/ do |rows|
  rows.raw.each do |row| 
    type = row.first
    count = row.second

    type_css_class = type.split(' ').join('-')
    page.should have_css(".#{type_css_class}-question .count", :text => count)
  end
end

Then /^the question "([^"]+)" should have the response stats:$/ do |question_title, rows|
  within(".app-assessment-template-question", :text => question_title) do
    rows.raw.each do |row|
      stats_type = row.first #correct incorrect skipped
      percent = row.second #width is the percent of the stats type e.g. 100, 75, 25
      page.should have_css(".percent-#{stats_type}.width-#{percent}")
    end
  end
end

Given /^the question "([^"]*)" is associated to the standards:$/ do |question_title, standards|
  question = Question.find_by_title(question_title)
  question.should be

  standards.raw.each do |row|
    standard_name = row.first
    standard_description = "Standard Desc: #{row.first}"

    standard = Standard.with_name(standard_name).first
    standard ||= Fabricate :standard, :name => standard_name, :description => standard_description

    question.classifications.create!(:standard_id => standard.id)
  end
end

Given /^there exists a multiple choice question named "([^"]+)" with standard classifications:$/ do |question_title, standards|
  question = repository.question title: question_title, description: question_title, with_answers: false

  standards.raw.each do |row|
    standard_name = row.first
    standard_description = row.second

    standard = Standard.with_name(standard_name).first
    standard ||= Fabricate :standard, :name => standard_name, :description => standard_description

    question.classifications.create!(:standard_id => standard.id)
  end
end

When /^there exists a multiple choice question "([^"]+)" with the following attributes:$/ do |question_title, attributes|
  question = step %(there exists a multiple choice question "#{question_title}")

  attributes.raw.each do |row|
    answer_body = row.first
    answer_correct = row.second == "true"
    Fabricate :multiple_choice_answer, :correct => answer_correct, :body => answer_body, :question => question
  end
end

Given /^there exists a (multiple choice|matching) question "([^"]+)"$/ do |question_type, question_title|
  question_type_symbol = "#{question_type} question".gsub(" ", "_").to_sym
  Fabricate question_type_symbol, :title => question_title, :description => question_title
end

Given /^I have a question #{S}$/ do |title|
  my.question = repository.question title: title
  repository.answer(correct: true)
end

Given /^I have a question with the attributes:$/ do |attributes|
  my.question = repository.question(Hash[attributes.raw])
end

When /^there exists a multiple choice question with the following attributes:$/ do |attributes|
  my.question = repository.question(with_answers: false)
  next_answer_correct = false

  attributes.raw.each do |row|
    name = row.first
    value = row.second

    if name =~ /question_description/
      my.question.description = value
    elsif name =~ /answer_body/
      repository.answer(body: value, correct: next_answer_correct)
      next_answer_correct = false
    elsif name =~ /answer_correct/
      next_answer_correct = true
    else #name =~ /question_description question_title etc/
      name =~ /question_(.+)/
      prop = "#{$1}="
      my.question.send(prop, value)
    end

  end
  
  my.question.save!
  view_questions
end

When /^there exists a short answer question with the following attributes:$/ do |attributes|
  question = Fabricate :short_answer_question
  
  attributes.raw.each do |row|
    case row.first
    when /description/, /title/, /numeric/
      question.update_attributes! row.first.to_sym => row.second
    when /answer/
      Fabricate :short_answer_answer, :body => row.second, :question => question
    else
      raise "Unknown question attribute passed in: #{row.first}"
    end
  end
end


When /^there exists a True\/False question with the following attributes:$/ do |rows|
  rows_hash = rows.rows_hash

  Fabricate(:true_false_question, organization: my.organization) do
    title rows_hash['title']
    description rows_hash['description']

    after_create do |question|
      answers = question.answers
      if rows_hash['correct answer'] == "true"
        answers.find_by_body("True").update_attributes!(:correct => true)
        answers.find_by_body("False").update_attributes!(:correct => false)
      else
        answers.find_by_body("True").update_attributes!(:correct => false)
        answers.find_by_body("False").update_attributes!(:correct => true)
      end
    end
  end
end

Given /^there exists standards with the attributes:$/ do |attributes|
  attributes.hashes.each do |row|
    name = row[:name]
    description = row[:description]
    parent = row[:parent]
    
    standard = Fabricate(:standard, :name => name, :description => description, :parent => Standard.find_by_name(parent))
    my.organization.standards << standard if !row.has_key?('org') || row[:org] == 'yes'
  end
end

Given /^there exists a matching question with the following attributes:$/ do |attributes|
  question = Fabricate :matching_question

  attributes.raw.each_with_index do |row, index|
    type = row.first

    if type == "description" || type == "title"
      question.update_attributes(type => row.second)
    else # match_answer
      Fabricate :matching_answer, :body => row.second, :match => row.third, :question => question, :position => index
    end
  end
end

Given /^there exists a course called "([^"]+)"$/ do |course_title|
  educator = Educator.find(:first)
  my.course = repository.course title: course_title, educators: [educator]
end

Given /^there exists an( published| unpublished)? assessment template named "([^"]+)" for course "([^"]+)"$/ do |published, assessment_template_title, course_title|
  available = published != " unpublished"
  course = Course.find_by_title(course_title)

  my.course = course || Fabricate(:course, :title => course_title) 
  my.user = my.course.educators.first
  educator = my.user
  assessment_template = AssessmentTemplate.find_by_title(assessment_template_title)
  
  my.assessment_template = assessment_template || Fabricate(:assessment_template, title: assessment_template_title, user: my.user)
  assessment = Assessment.find_by_assessment_template_id_and_course_id(my.assessment_template.id, my.course.id)
  my.assessment = assessment || Fabricate(:assessment, :course => my.course, :available => available, :assessment_template => my.assessment_template)
end

Given /^there exists a(?:n|)( published| unpublished)? assessment template named "([^"]+)" for course "([^"]+)" with the questions:$/ do |published, assessment_template_title, course_title, rows|
  step %(there exists an#{published} assessment template named "#{assessment_template_title}" for course "#{course_title}") 
  rows.raw.each_with_index do |row, index|
    question = Question.find_by_title(row.first)
    question.should be
    Fabricate :assessment_template_question, question: question, points: row.second, position: index, assessment_template: my.assessment_template
  end
end

Given /^the template named #{S} does not allow students to take notes$/ do |template_title|
  assessment_template = AssessmentTemplate.find_by_title(template_title)
  assessment_template.allow_notes = false
  assessment_template.save!
end

Then /^I should not see the notes tab for the question$/ do
  page.should_not have_css('.app-notes')
end

Given /^there exists a student "([^"]+)" in my course$/ do |student_name| 
  student = repository.student(first_name: student_name) 
  my.student = student
  my.students << student
end

Given /^there exists a student "([^"]+)" with the courses:$/ do |student_name, rows| 
  student = Fabricate :student, first_name: student_name, last_name: student_name

  rows.raw.each_with_index do |row, index|
    course = Course.find_by_title(row.first)
    student.courses << course
    student.save!
  end
end

Given /^there exists a (proctor|creator) "([^"]+)" with the courses:$/ do |role, educator_name, rows| 
  educator = Fabricate role.to_sym, first_name: educator_name
  my.user = educator
  my.organization = educator.organization
  my.school = repository.school
  
  rows.raw.each_with_index { |row, index| repository.course(title: row.first) }
end



Given /^the assessment for the student "([^"]+)" should be (not-started|in-progress|unscored|completed)$/ do |student_name, state|
  view_student_overview_tab
  within(".#{state}") do
    page.should have_css(".student", :text => student_name)
  end
end

Given /^the student "([^"]+)" should have the score "([^"]+)"$/ do |student_name, score|
  within('tr', :text => student_name) do
    should have_css('.app-percent-correct', :text => score)
  end
end

Given /^there exists an essay question with the following attributes:$/ do |rows|
  question = Fabricate :essay_question
  rows.raw.each do |row|
    question.update_attributes! row.first.to_sym => row.second
  end
end

Given /^I login as the student "([^"]+)"$/ do |student_name|
  student = Student.find_by_name(student_name)
  unless student.present?
    steps %Q{
      Given there exists a student "#{student_name}" with the courses: 
        | Math |
    }
    student = Student.find_by_name(student_name)
  end

  step %(I go to the home page)
  step %(I fill in "user_username" with "#{student.username}")
  step %(I fill in "user_password" with "abc123")
  step %(I press "Sign in")
end


Given /^I login as the educator "([^"]+)"$/ do |educator_name|
  educator = Educator.find_by_name(educator_name)
  step %(I go to the home page)
  step %(I fill in "user_username" with "#{educator.username}")
  step %(I fill in "user_password" with "abc123")
  step %(I press "Sign in")
  my.user = educator
  my.organization = my.user.organization
end

Given /^I login as a(?:n|) (proctor|educator|creator)$/ do |role| 
  educator = Educator.find(:first)
  if educator.present?
    my.user = educator
    my.organization = my.user.organization
    step %(I login as the educator "#{educator.name}")
  else
    my.organization = repository.organization
    my.school = repository.school
    my.user = repository.send role.to_sym
    my.courses << repository.course(title: 'Math')

    my.course = my.user.courses.first
    step "I login"
  end
end


Then /^I should not see any question previews$/ do
  page.should_not have_css('#question-preview[aria-hidde=true]')
end

When /^I preview the question #{S}$/ do |title|
  current_path = URI.parse(current_url).path
  if current_path =~ /edit/
    open_question_options()
    step %(I follow "Preview")
  else
    within('.questions-table-all .item', :text => title) do
      find('.app-preview').click
    end
  end

  wait_until { has_css?("#question-preview", :visible => true)}
end

Then /^I hover the question #{S}$/ do |question_title|
  page.find('.app-question-row', :text => question_title).trigger('mouseover')
  wait_for_ajax_completion
end

When /^I open the page menu$/ do
  open_assessment_template_options
end

def within_popup(popup_preview)
  preview_css = popup_preview == "preview" ? "#question-preview" : ".popover"
  within(preview_css) do
    yield
  end
end

When /^I delete the answer$/ do
  handle_js_confirm(true) do
    find(".delete-button-blank").click
  end
end

Then /^I should see the essay question (popup|preview) with the following attributes:$/ do |popup_preview, rows|
  within_popup(popup_preview) do
    page.should have_css('textarea')

    rows.raw.each do |row|
      case row.first
      when /description/
        page.should have_css('.description', :text => row.second)
      when /standard/
        page.should have_css('.standard', :text => row.second)
      when /media asset/
        within('.media-assets .media-asset', :text => row.second) do
          page.should have_css("img[src$='#{row.third}']")
        end
      else
        raise Exception, "Unexpected value #{row.first} in the first column"
      end
    end
  end
end

Then /^I should see the short answer question (popup|preview) with the following attributes:$/ do |popup_preview, rows|
  within_popup(popup_preview) do
    page.should have_css('input')

    rows.raw.each do |row|
      case row.first
      when /description/
        page.should have_css('.description', :text => row.second)
      when /media asset/
        within('.media-assets .media-asset', :text => row.second) do
          page.should have_css("img[src$='#{row.third}']")
        end
      else
        raise Exception, "Unexpected value #{row.first} in the first column"
      end
    end
  end
end

Then /^I should see the True\/False question (popup|preview) with the following attributes:$/ do |popup_preview, rows|
  within_popup(popup_preview) do
    page.should have_css('ol.answers')
    page.should have_css('li.answer', :count => 2)
    page.should have_css('li.answer', :text => 'True')
    page.should have_css('li.answer', :text => 'False')

    rows.raw.each do |row|
      case row.first
      when /description/
        page.should have_css('.description', :text => row.second)
      when /media asset/
        within('.media-assets .media-asset', :text => row.second) do
          page.should have_css("img[src$='#{row.third}']")
        end
      else
        raise Exception, "Unexpected value #{row.first} in the first column"
      end
    end
  end
end

Then /^I should see the matching question (popup|preview) with the following attributes:$/ do |popup_preview, rows|
  within_popup(popup_preview) do
    rows.raw.each do |row|
      case row.first 
      when /description/
        page.should have_css('.description', :text => row.second)
      when /matching/
        choice = row.second
        match = row.third

        within('.answers.choices') do 
          page.should have_css(".answer", :text => choice)
        end

        within('.answers.matches') do
          page.should have_css(".answer", :text => match)
        end
      when /media asset/
        within('.media-assets .media-asset', :text => row.second) do
          page.should have_css("img[src$='#{row.third}']")
        end
      else
        raise Exception, "Unexpected value #{row.first} in the first column"
      end
    end
  end
end

Then /^I should see the multiple choice question (popup|preview) with the following attributes:$/ do |popup_preview, rows|
  within_popup(popup_preview) do
    rows.raw.each do |row|
      case row.first 
      when /description/
        page.should have_css('.description', :text => row.second)
      when /answer/
        body = row.second
        within('.answers') do 
          page.should have_css(".answer .body", :text => body)
        end
      when /media asset/
        within('.media-assets .media-asset', :text => row.second) do
          page.should have_css("img[src$='#{row.third}']")
        end
      else
        raise Exception, "Unexpected value #{row.first} in the first column"
      end
    end
  end
end

Given /^there exists a media asset titled "([^"]+)" with the file name "([^"]+)" for the question "([^"]+)"$/ do |media_title, media_filename, question_title|
  media_file = File.open(Rails.root.join("features/fixtures/", media_filename))
  media_asset = Fabricate(:media_asset, :title => media_title, :file => media_file)

  question = Question.find_by_title(question_title)
  question.media_assets << media_asset
end

When /^I close the preview$/ do
  find('#question-preview .close').click
end

When /^I should see the (multiple-choice|true-false) question "([^"]*)" as question number "([\d]+)" with the answers:$/ do |question_type, question_description, question_order, answers|
  #within_window(page.driver.browser.window_handles.last) do
    within("#question-#{question_order}.#{question_type}-question") do
      page.should have_css('.description', :text => question_description)
      within('.answers') do
        answers.raw.each do |answer|
          page.should have_css('.body', :text => answer.first)
        end
      end
    end
  #end
end


When /^I click the browser back button$/ do
  page.evaluate_script('window.history.back()')
end

When /^I try to take "([^"]*)" for "([^"]*)" in another tab$/ do |assessment_title, course_title|
  assessment_template = AssessmentTemplate.find_by_title assessment_title
  assessment_template.should be
  course = Course.find_by_title(course_title)
  course.should be
  assessment = Assessment.find_by_assessment_template_id_and_course_id(assessment_template.id, course.id)

  path = students_assessment_assessment_responses_path(:assessment_id => assessment.id)
  page.execute_script("$.post('#{path}');")
  sleep 2 # wait for Ajax POST to complete
end

When /^the assessment template "([^"]+)" attributes:$/ do |assessment_template_title, rows|
  assessment_template = AssessmentTemplate.find_by_title assessment_template_title
  assessment_template.should be

  assessment_template.update_attributes! rows.rows_hash
end

Then /^the response "([^"]+)" notes should be "([^"]+)"$/ do |response_title, content|
  within('.app-response', :text => response_title) do
    page.find('[name=notes]').value.should == content
  end
end

And /^I toggle advanced options$/ do
  open_advanced_assessment_template_options()
end

Then /^I should see the following questions in the assessment:$/ do |rows|
  page.should have_css('.question', :count => rows.raw.count)
  rows.raw.each do |row|
    page.should have_css('.question', :text => row.first)
  end
end

Then /^I should see the following questions with title:$/ do |rows|
  expected_visible_question_titles = rows.raw.map(&:first)
  expected_visible_question_titles.each do |title|
    page.should have_css('.item', :text => title, :visible => true)
  end

  all_question_titles = page.all('#questions .item').map do |question_el|
    question_el.find('.title').text
  end

  expected_hidden_question_titles = all_question_titles - expected_visible_question_titles
  expected_hidden_question_titles.each do |title|
    page.should have_css('.item', :text => title, :visible => false)
  end
end

Then /^I should see the Complete page$/ do
  page.should have_content("Thank you for trying your best!")
end

When /^I finish reading the instructions and start the assessment "([^"]*)"$/ do |delivery_method| 
  begin_assessment(delivery_method)
end

When /^I finish reading the instructions and start the assessment$/ do
  begin_sequential_assessment
end

And /^I clear the following questions:$/ do |rows|
  rows.raw.each do |row|
    question_description = row.first
    within(".app-question-type", :text => question_description) do
      page.find('.app-clear').click
    end
  end
end

Then /^the following questions should not have any responses:$/ do |rows|
  rows.raw.each do |row|
    question_description = row.first
    question_el = page.find(".question .app-question-type", :text => question_description)

    within("##{question_el[:id]}") do
      question_type = question_el[:'data-question-type']
      case question_type
      when /multiple_choice_question/, /true_false_question/
        page.should_not have_css('.answer.active')
      when /short_answer_question/, /essay_question/
        page.find('.answer').value.should be_empty
      when /matching_question/
        page.should_not have_css('.answers.choices .answer.hidden')
        page.should_not have_css('.answers.matches .answer.hidden')
        page.should_not have_css('.pairs.answers .answer-item')
      else
        raise "Unknown or empty question type: #{question_type}"
      end
    end
  end
end

Given /^the multiple choice question titled "([^"]+)" has the following images as the answers:$/ do |question_title, rows|
  question = Question.find_by_title question_title
  question.should be

  rows.raw.each do |row|
    file_name = row.first
    correct = row.second

    # Create media asset
    image_file = File.open Rails.root.join("features/fixtures/", file_name)
    media_asset = Fabricate :media_asset, :file => image_file, :title => ""

    # Assign it to a new answer
    answer = Fabricate(:multiple_choice_answer, question: question, correct: (correct == "correct"))
    question.answers << answer
    answer.media_assets << media_asset
  end
end

Given /^the matching question titled "([^"]+)" has the following images as the answers:$/ do |question_title, rows|
  question = Question.find_by_title question_title
  question.should be

  rows.raw.each_with_index do |row, index|
    choice_filename = row.first
    match_filename = row.second

    choice_media_asset = Fabricate :media_asset, :file => to_test_file(choice_filename), :title => ""
    match_media_asset = Fabricate :media_asset, :file => to_test_file(match_filename), :title => ""

    answer = Fabricate :matching_answer, :question => question, :body => "", :match => "", :position => index

    answer.media_assets << choice_media_asset
    answer.match_media_assets << match_media_asset
  end
end

def to_test_file(filename)
  File.open Rails.root.join("features/fixtures/", filename)
end

Given /^there exists "([^"]+)" questions of random types in the system$/ do |num_questions|
  question_types = {
    1 => :multiple_choice_question_with_answers,
    2 => :essay_question,
    3 => :short_answer_question_with_answers,
    4 => :true_false_question,
    # intentionally left out matching because it's hard to make response for matching types
  }

  num_questions.to_i.times do |index|
    question_type = question_types[rand(1..question_types.count)]
    question_title = "Question #{index}"

    Fabricate question_type, :title => question_title, :description => question_title
  end
end

Then /^I should see the question indicator toggle$/ do 
  within(".app-option-toggle[data-field='question_indicator']") do
    page.should have_css('.app-option.app-yes')
    page.should have_css('.app-option.app-no')
  end
end

Given /^I choose to (enable|disable) the question indicator$/ do |toggle|
  body_classes = find('#assessment-templates-edit')[:class].split(' ')

  within(".app-option-toggle[data-field='question_indicator']") do
    if toggle == "enable"
      click_css(".app-option.app-yes")
    else
      click_css(".app-option.app-no")
    end
  end
end

def indicator_class(index)
  number_of_indicators = 50
  "indicator-#{(index % number_of_indicators) + 1}"
end

Then /^I should see the appropriate question indicator for each in-full question$/ do 
  sleep(3) #wait for input
  questions = page.all('.indicator-true #questions .question .question-content')
  questions.size.should be > 0
  questions.each_with_index do |question, index|
    css_classes = question[:class]
    css_classes.should include 'question-indicator'
    css_classes.should include indicator_class(index)
  end
end

Then /^the assessment should have the #{S} delivery option$/ do |delivery_method|
  page.should have_css(".app-delivery-#{delivery_method}")
end

Then /^I should see the appropriate question indicator for each sequential question$/ do 
  question_index = 0

  while page.has_css?('.app-next-question')
    question = page.find('.indicator-true #current-question .question .question-content')
    css_classes = question[:class]
    css_classes.should include 'question-indicator'
    css_classes.should include indicator_class(question_index)

    steps %(And I advance the question)

    question_index += 1
  end
end

Then /^I should not see the question indicator for each in-full question$/ do 
  sleep(3)
  questions = page.all('.indicator-false #questions .question .question-content')
  questions.size.should be > 0
  
  # the visible flag only appears to work when it's set to true checking visible: false did not error 
  page.should have_css('.safety-icon')
  page.should_not have_css('.safety-icon', :visible => true)
end

Then /^I should not see the question indicator for each sequential question$/ do
  question_index = 0

  while page.has_css?('.app-next-question')
    question = page.find('.indicator-false #current-question .question .question-content')
    css_classes = question[:class]
    css_classes.should include 'question-indicator'
    css_classes.should include indicator_class(question_index)

    steps %(And I advance the question)

    question_index += 1
  end
end

And /^I disable _blank link targets$/ do
  page.execute_script %($("a[target='_blank']").removeAttr("target"))
end

When /^I set the assessment template to( not)? be retriable$/ do |not_retriable|
  body_classes = find('#assessment-templates-edit')[:class].split(' ')

  within(".app-option-toggle[data-field='retriable']") do
    if not_retriable.present?
      click_css('.app-option.app-no')
    else
      click_css('.app-option.app-yes')
    end
  end
end


Then /^I advance the question$/ do
  page.find('.app-next-question').click
end

Then /^I turn in the assessment$/ do
  turn_in_assessment
end

Then /^I start to turn in the assessment$/ do
  click_turn_in_assessment
end

Then /^I should be on the question "([^"]+)"$/ do |question_description|
  page.should have_css('.question', :text => question_description)
end

When /^I toggle question filter$/ do
  page.find('.show-filter').click
end

When /^I filter the questions using the keyword "([^"]+)"$/ do |keyword|
  fill_in('question-filter-keyword', :with => keyword)
end

Then /^I should not see any questions listed$/ do
  page.find('#questions .item', :count => 0)
end

Then /^I should see "([^"]*)" as the assessment template notes$/ do |notes|
  page.find("#app-notes textarea[name=notes]").value.should == notes
end

When /^I fill in the assessment template notes with "([^"]*)"$/ do |notes|
  fill_in('notes', :with => notes)
end

When /^I save the assessment template notes$/ do
  page.find('#app-notes .app-save').click
end

Then /^I should see the progress bar at #{S} of #{S}$/ do |position, question_count|
page.find('.app-finished-percentage').text.should == "Question #{position} of #{question_count}"
end

When /^for each question, I fill in the following notes and click save on each:$/ do |table|
  table.hashes.each do |row|
    within('.question', :text => row['question_description']) do
      page.find('.app-show-button').click
      fill_in('notes', :with => row['notes'])
      page.find('.app-save-notes').click
    end
  end
end

When /^I filter the questions using the standard "([^"]+)"$/ do |standard_name|
  step %{I follow "Filter Standards"}
  standard_to_align = Standard.find_by_name standard_name
  standard_to_align.ancestors.map do | ancestor_standard |
    step %{I click the standard with text "#{ancestor_standard.name}" within "#standards"}
  end

  step %{I click the standard with text "#{standard_to_align.name}" within "#standards"}
end

When /^I view my course$/ do 
  view_course(my.course)
end

When /^I assign the course "([^"]*)" to the current assessment template$/ do |course_title|
  steps %(And I go to the dashboard)
  view_course(course_title)
  click_css('.app-verify-course') if page.has_css?('.app-verify-course')

  within('.app-assessment-template') do
    find('.app-assign').click
  end
end

Then /^I should see the starting information$/ do
  page.should_not have_css(".app-course")
  page.should have_css(".app-starting-information")
end

When /^I choose the assessment #{S} for the #{S} course for the standards report$/ do |assessment_name, course_name|
  smart_select assessment_name, from: 'app-assessment-selection', group: course_name
end

When /^I generate the report$/ do
  click_css('.app-generate-report')
end

Given /^I have created (?:an|another) assessment named #{S} with standards:$/ do |assessment_name, standards|
  create_assessment_with_standards_for_educator(Educator.first, assessment_name, standards)
end

def create_assessment_with_standards_for_educator(educator, assessment_name, standards)
  my.assessment_template = Fabricate(:assessment_template, title: assessment_name, user: educator)
  course = my.course
  my.assessment = Fabricate(:assessment, course: course, assessment_template: my.assessment_template)

  standards.rows.each do |standard_row|
    create_question_and_standard(standard_row[0], my.assessment_template)
  end
end

def create_question_and_standard(standard_name, template)
  question = Fabricate(:question)
  standard = Standard.find_by_name(standard_name) || Fabricate(:standard, name: standard_name)
  my.organization.standards << standard unless my.organization.standards.include?(standard)
  Fabricate(:classification, question: question, standard: standard)
  Fabricate(:assessment_template_question, question: question, assessment_template: template, points: 100)
end

When /^I fill in the credentials of a (proctor|educator|student|substitute)$/ do |user_type|
  fill_in("user_username", with: (Fabricate user_type.downcase.to_sym).username)
  fill_in("Password", with: 'abc123')
end

When /^I activate the as\-a\-student option$/ do
  find("[data-toggle-selector='.app-login-as-student']").click()
  wait_until { has_css?('#login_as_student', :visible => true) }
  find(:css, "#login_as_student").set(true)
end

When /^I sign in$/ do
  click_button("Sign in")
end

Then /^I should see the student selection page$/ do
  page.should have_css("#students-index")
end

Then /^I should see the (educator|student) dashboard$/ do |dashboard_type|
  page.should have_css("##{dashboard_type == 'student' ? 'student-' : ''}dashboards-show")
end

When /^I fill in #{S} with #{S} using rich text$/ do |field, value|
  fill_in_wysiwyg_content(value, field)
end

When /^I fill in tiny mce with #{S}$/ do |value| 
  fill_in_wysiwyg_content(value)
end

When /^I cancel the form$/ do
  cancel_form
end

Given /^I have a student in my course$/ do
  my.students << repository.student
end

Given /^I have students in my course$/ do
  my.students << repository.student
  my.students << repository.student
end

def simulate_click_on(selector, offset_x, offset_y)
  page.evaluate_script <<-EOF
    (function() {
      var element = $("#{selector}").get(0);
      var reflow = function(element, force) {
        if (force || element.offsetWidth === 0) {
          var prop, oldStyle = {}, newStyle = {position: "absolute", visibility : "hidden", display: "block" };
          for (prop in newStyle)  {
            oldStyle[prop] = element.style[prop];
            element.style[prop] = newStyle[prop];
          }
          element.offsetWidth, element.offsetHeight; // force reflow
          for (prop in oldStyle)
            element.style[prop] = oldStyle[prop];
        }
      };

      var mouseTrigger = function(eventName, options) {
        var eventObject = document.createEvent("MouseEvents");
        eventObject.initMouseEvent(eventName, true, true, window, 0, 0, 0, options.clientX || 0, options.clientY || 0, false, false, false, false, 0, null);
        element.dispatchEvent(eventObject);
      }

      var pos = {
        x: #{offset_x},
        y: #{offset_y}
      };

      reflow(element);
      mouseTrigger("mousedown", { clientX: pos.x, clientY: pos.y });
      pos.x += 1; pos.y += 1;
      mouseTrigger("mousemove", { clientX: pos.x, clientY: pos.y});
      mouseTrigger("mouseup", { clientX: pos.x, clientY: pos.y});
      mouseTrigger("click", { clientX: pos.x, clientY: pos.y});
    })();
  EOF
end

def drag_element_by(selector, offset_x, offset_y)
  page.evaluate_script <<-EOF
    (function() {
      var element = $("#{selector}").get(0);

      var reflow = function(element, force) {
        if (force || element.offsetWidth === 0) {
          var prop, oldStyle = {}, newStyle = {position: "absolute", visibility : "hidden", display: "block" };
          for (prop in newStyle)  {
            oldStyle[prop] = element.style[prop];
            element.style[prop] = newStyle[prop];
          }
          element.offsetWidth, element.offsetHeight; // force reflow
          for (prop in oldStyle)
            element.style[prop] = oldStyle[prop];
        }
      };

      var mouseTrigger = function(eventName, options) {
        var eventObject = document.createEvent("MouseEvents");
        eventObject.initMouseEvent(eventName, true, true, window, 0, 0, 0, options.clientX || 0, options.clientY || 0, false, false, false, false, 0, null);
        element.dispatchEvent(eventObject);
      }

      var centerPosition = function(element) {
        reflow(element);
        var rect = element.getBoundingClientRect();
        var position = {
          x: rect.width / 2,
          y: rect.height / 2
        };
        do {
            position.x += element.offsetLeft;
            position.y += element.offsetTop;
        } while ((element = element.offsetParent));
        position.x = Math.floor(position.x), position.y = Math.floor(position.y);

        return position;
      };

      pos = centerPosition(element);
      mouseTrigger("mousedown", { clientX: pos.x, clientY: pos.y })
      mouseTrigger("mousemove", { clientX: pos.x + #{offset_x}, clientY: pos.y + #{offset_y} })
      mouseTrigger("mouseup",   { clientX: pos.x + #{offset_x}, clientY: pos.y + #{offset_y} })
    })();
  EOF
end
