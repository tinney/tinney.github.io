def handle_js_confirm(accept=true)
  page.evaluate_script "window.original_confirm_function = window.confirm"
  page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
  yield
  page.evaluate_script "window.confirm = window.original_confirm_function"
end

def confirm_question_delete
  click_css(".app-delete-confirm")
end

def activate_training_mode
  open_user_utilities
  click_css(".app-activate-training")
  page.should have_css('body')
end

def deactivate_training_mode
  open_user_utilities
  click_css(".app-nav .app-organization a")
  page.should have_css('body')
end

def reset_training_mode
  click_css(".app-reset-training")
end

def edit_rubric(rubric)
  within(".app-rubric", text: rubric.title) do
    click_link("Edit")
  end
end

def delete_rubric
  click_css('.app-delete')
end

def view_students
  within(".app-nav") do
    click_link("Students")
  end
end

def view_training
  within(".app-nav") do
    click_link("Training")
  end
end

def view_rubrics
  within(".app-nav") do
    click_link("Rubrics")
  end
end

def view_dashboard
  within(".app-nav") do
    click_link("Dashboard")
  end
end

def assign_rubric(rubric_title)
  within('.app-rubrics') do
    choose rubric_title
  end
end

def edit_student(student)
  within(".app-student", text: "#{student.last_name}, #{student.first_name}") do
    click_link("Edit")
  end
end

def merge_student(student)
  within(".app-student", text: "#{student.last_name}, #{student.first_name}") do
    click_link("Merge")
  end
end

def remove_student(student)
  within(".app-student", text: "#{student.last_name}, #{student.first_name}") do
    click_link("Remove")
  end
end

def view_students
  within(".app-nav") do
    click_link("Students")
  end
end

def view_standards
  within("#nav") do
    click_link("Standards")
  end
end

def view_administrator_users
  within("#nav") do
    click_link("Users")
  end
end

def edit_standard(standard_name)
  view_standards
  find('.app-standard', text: standard_name).find('.app-edit').click
end

def view_course_groups
  within(".app-nav") do
    click_link("Courses")
  end
end

def view_cohorts
  within(".app-nav") do
    click_link("Cohorts")
  end
end

def edit_cohort(course)
  view_cohorts
  within(".app-course", text: course.title) do
    click_css(".app-edit")
  end
end

def view_courses
  within(".app-nav") do
    click_link("Courses")
  end
end

def create_component
  find('.app-add-component').click
end

def create_rubric
  find('.app-new-rubric').click
end

def trigger_blur_on(selector)
  page.driver.browser.execute_script("$('#{selector}').trigger('blur')")   
end

def view_student_overview_tab
  return if has_css?('#app-student-overview', :visible => true)

  click_link("Student Overview")

  wait_until do
    has_css?('#app-student-overview', :visible => true)
  end
end

def view_assessment_overview_tab
  return if has_css?('#app-assessment-overview', :visible => true)
  click_link("Assessment Overview")

  wait_until do
    has_css?('#app-assessment-overview', :visible => true)
  end
end

def logged_in?
  #assumed this is used with visit root_path()
  !page.has_css?('#devise-sessions-new')
end

def login_as(user)
  visit root_path()
  return if logged_in?
  fill_in("user_username", with: user.username)
  fill_in("Password", with: 'abc123')
  click_button("Sign in")
end

def refresh
  visit page.driver.browser.current_url
end

def delete_assessment
  find('.app-assessment-delete').click
end

def score_question(question)
end

def view_assessment(assessment)
  #dashboard
  if page.has_css?("#building-administration-course-groups-index") || page.has_css?("#dashboards-show") || page.has_css?('#course-groups-index')
    within(".app-course", text: assessment.course.title) do
      within(".app-assessment", text: assessment.name) do
        find('.app-assessment-report').click
      end
    end
  else #admin
    page.find('.app-assessment a', text: assessment.name).click
  end
end

def view_assessment_response(assessment_response)
  view_dashboard
  view_assessment(assessment_response.assessment)

  wait_until do
    has_css?('#app-student-overview', :visible => true)
  end
  click_link(assessment_response.student_name)
end

def view_assessment_overview(assessment)
  within(".app-assessment-templates", text: assessment.assessment_template.title) do
    click_link(assessment.name)
  end
end

def edit_assessment_template(assessment_template)
  view_assessment_templates
  within(".app-assessment-template", text: assessment_template.title) do
    click_link("Edit")
  end
end

def edit_question(question_title)
  view_questions
  click_css('.app-question', :text => question_title)
end

def edit_answer(answer)
  edit_question answer.question.title
  within('.answer-item', :text => answer.body) do
    click_css('.app-edit')
  end
end

def save_assessment_template
  page.driver.browser.execute_script("$('.app-save').trigger('click')")   
end

def view_assessment_templates
  click_link("Assessments")
end

def view_questions
  within(".app-nav") do
    click_link("Questions")
  end
end

def open_assessment_template_options
  find('#status-options .dropdown-toggle').click 
end

def open_bootstrap_dropdown
  find('.dropdown-toggle').click 
end

def preview_assessment_template
  open_assessment_template_options
  find(".preview a").click
end

def open_advanced_assessment_template_options
  unless has_css?('.advanced-options', :visible => true) 
    find('.toggle-advanced-options').click
  end
end

def open_question_options
  find('#status-options .app-question-options-toggle').click 
end

def open_user_utilities
  click_css '.app-user-utils-opener'
end

def logout
  if has_css?('.app-user-utilities-toggle')
    find('.app-user-utilities-toggle').click
  elsif has_css?('.app-return-to-dashboard')
    find('.app-return-to-dashboard').click
  end
  
  find('.app-logout').click
  accept_modal if has_css?('.take-assessment')
end

def wait_for_mce
  sleep(1)
  #wait_until { has_css?('#assessment_instructions_ifr') }
end

def fill_in_wysiwyg_content(content, field=nil)
  sleep 1 # wait for TinyMCE to style the content region
  if field.present?
    page.evaluate_script %(tinyMCE.get("#{field}").setContent("#{content}");)
  else
    page.evaluate_script %(tinyMCE.activeEditor.setContent("#{content}");)
  end
end

def get_wysiwyg_content(field=nil)
  if field.present?
    page.evaluate_script %(tinyMCE.get("#{field}").getContent();)
  else
    page.evaluate_script %(tinyMCE.activeEditor.getContent();)
  end
end

def start_assessment(assessment_title)
  within('.app-assessment', :text => assessment_title) do
    click_button("Start")
  end
end

def begin_assessment(mode='full')
  page.find(".app-delivery-#{mode} a.app-begin").click
end

def begin_sequential_assessment
  begin_assessment("sequential")
end

def click_turn_in_assessment
  page.find('.app-complete-assessment').click
  sleep(2)
end

def turn_in_assessment
  click_turn_in_assessment
  accept_modal
end

def accept_modal
  wait_until do
    find(".modal[aria-hidden=false]")
  end

  within('.modal') do
    page.find('.app-action-accept').click
  end
end

def go_to_next_question
  find('.app-next-question').click
  sleep(2)
  wait_for_ajax_completion
end

def page_has_next_question?
  page.has_css?('.app-next-question')
end

def answer_question_and_go_to_next
  find('.answer').click
  go_to_next_question
end

def should_see_question_by_index(index)
  find(".app-question-number", text: index.to_s)
end

def resume_assessment(assessment_title, course_title, args={})
  within('.app-resumable-assessments .app-assessment', :text => assessment_title) do
    click_link("Resume")
  end
  begin_sequential_assessment if args[:begin] == :sequential
end

def view_program_reports(program_title)
end

def view_program(program_title)
  program_title = program_title.title if program_title.respond_to?(:title)
  within('.app-program', text: program_title) do
    find('a').click
  end
end

def create_organization
  click_css '.app-new-organization'
end

def edit_organization(title)
  within('.app-organization', text: title) do
    click_css(".app-edit")
  end
end

def view_organization(title)
  page.find('.app-organization', text: title).find('.app-view').click
end

def view_users
  find('.app-org-users .app-edit').click
end

def submit_form(args={})
  page.find('.app-submit').click
  wait_for_ajax_completion unless args[:do_not_wait_for_ajax]
end


def cancel_form
  page.find('.app-cancel').click
end

def view_programs
  visit programs_path unless page.has_css?('.program-subscriptions')
end

def edit_program(program_title)
  view_programs
  page.find('.app-program', text: program_title).find('.app-edit').click
end

def edit_program_subscriptions(program_title)
  visit programs_path unless page.has_css?('.program-subscriptions')
  page.find('.app-program', text: program_title).find('.app-edit').click
end

def edit_resource_in_organization(resource, organization)
  page.find('.app-organization', text: organization).find(".app-org-#{resource} .app-edit").click
end

def view_program_organization(organization)
  page.find('.app-organization', text: organization.title).click
end

def view_course(course)
  title = course.is_a?(Course) ? course.title : course 
  click_on(title)
end

def verify_course(course)
  view_course(course)
  click_css('.app-verify-course')
end

def see_nonempty_smart_select(options)
  trigger = options[:multiple] ? "#s2id_#{options[:from]} input" : "#s2id_#{options[:from]} a"
  click_css trigger

  page.should have_css("li.select2-result-selectable")
end

def smart_select(text, options)
  trigger = options[:multiple] ? "#s2id_#{options[:from]} input" : "#s2id_#{options[:from]} a"
  click_css trigger
  # XXX why does screenshot close the box?
  # screenshot_and_open_image
  if options[:group]
    if page.all(".select2-result-with-children", text: options[:group]).present?
      within(".select2-result-with-children", text: options[:group]) do
        item = find("li.select2-result-selectable", text: text)
        return item.click if item
      end
    end
  else
    item = find("li.select2-result-selectable", text: text)
    return item.click if item
  end
  click_css trigger 
end

def select_no
  find(".app-option.app-no").click
  wait_for_ajax_completion
end

def select_yes
  find(".app-option.app-yes").click
  wait_for_ajax_completion
end

def admin_organization(organization_title)
  return if page.has_css?('.app-administration-organization-show', text: organization_title)
  within(".app-organization", text: organization_title ) do
    page.find('.app-view').click
  end
end

def create_student
  find(".app-create-student").click
end

def create_educator
  find(".app-create-educator").click
end

def check_role(role_name)
  within('.app-role', text: role_name) do
    check 'user_role_ids_'
  end
end

def view_reports
  within(".app-nav") do
    click_link("Reports")
  end
end

def view_report(report_type)
  view_reports
  choose(report_type.to_s)
end

def generate_report
  click_css('.app-generate-report')
end

def release_assessment_scores_by_defaults
  select "Scores",
    from: "app-response-released-default"
  wait_for_ajax_completion
end

def see_students_assessment_score_released(student)
  within(".app-student[data-student-id='#{student.id}']") do
    find(".app-release-score").should be_checked
  end
end

def see_students_assessment_score_not_released(student)
  within(".app-student[data-student-id='#{student.id}']") do
    find(".app-release-score").should_not be_checked
  end
end

def see_released_default_for_assessment(value)
  find('#app-response-released-default').value.should == value
end
