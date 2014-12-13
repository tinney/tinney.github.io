class Repository
  def initialize(world)
    @my = world.my
    @their = world.their
    @world = world
  end
  
  def create_roles
    [:proctor, :creator, :building_administrator, :organization_administrator, :program_administrator, :administrator].each_with_index do |role_name, weight|
      Role.create!(title: role_name, weight: weight)
    end
  end

  def iris_config(args = {})
    ctx = context(args)
    Fabricate(:iris_config, args.reverse_merge(code: :delta_math, programs: [ctx.program]))
  end

  def rubric(args = {})
    ctx = context(args)
    Fabricate(:rubric, args.reverse_merge(organization: ctx.organization))
  end

  def historical_assessment(args={})
    ctx = context(args)
    Fabricate(:historical_assessment, args.reverse_merge(organization: ctx.organization))
  end

  def historical_assessment_result(args={})
    ctx = context(args)
    Fabricate(:historical_assessment_result, 
              args.reverse_merge(historical_assessment: ctx.historical_assessment,
                                student: ctx.students.first,
                                standard: ctx.organization.standards.first))
  end

  def switch_to_training_organization(organization, args={})
    ctx = context(args)
    UserManager.update_organization(ctx.user, organization.id)
  end

  def training_organization(args={})
    ctx = context(args)
    TrainingOrganizationManager.create_or_reset!(ctx.user).tap do |org|
      ctx.user.reload
    end
  end

  def rubric_component(args = {})
    ctx = context(args)
    descriptors = RubricComponentDescriptorManager.build(
      args.delete(:descriptors) || [
        {body: Faker::Lorem.paragraph}, 
        {body: Faker::Lorem.paragraph}
    ])

    Fabricate(:rubric_component, args.
                reverse_merge(rubric: ctx.rubric,
                              rubric_component_descriptors: descriptors))
  end

  def program(args={})
    ctx = context(args)
    ProgramManager.build!({organization: ctx.organization, title: Faker::Company.name}.merge(args))
  end

  def add_program_to_my_course(program, args={})
    ctx = context(args)
    course = ctx.course

    CourseManager.create_program_subscription!(course, program)
  end

  def add_program_to_my_courses(program, args={})
    ctx = context(args)

    ctx.courses.each do |course| 
      CourseManager.create_program_subscription!(course, program)
    end
  end

  def add_course_to_my_course_group(course, args={})
    ctx = context(args)
    ctx.course_group.courses << course
  end

  def add_user_to_my_course_group(user, args={})
    ctx = context(args)
    ctx.course_group.users << user
  end

  def add_organization_to_my_program(organization, args={})
    ctx = context(args)
    ProgramManager.connect_organization_and_program(ctx.program, organization)
  end
  
  def program_assessment_template(args={})
    template = create_naked_template(args)
    context(args).program.assessment_templates << template
    template
  end
  
  def student(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization
    args[:courses] ||= [ctx.course]

    Fabricate(:student, args)
  end

  def administrator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:admin, args)
  end

  def educator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:educator_with_course, args)
  end
  
  def creator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    user = Fabricate(:creator, args)
  end

  def program_administrator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    user = Fabricate(:program_administrator, args)
  end
  
  def naked_educator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:educator, args)
  end

  def program_administrator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:program_administrator, args)
  end

  def proctor(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:proctor, args)
  end

  def building_administrator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:building_administrator, args)
  end

  def organization_administrator(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:organization_administrator, args)
  end
  
  def assessment_template(args={})
    ctx = context(args)
    AssessmentTemplateManager.build!(ctx.user, args).tap do |template| 
      template.update_attributes(args)
    end
  end

  def assessment_template_question(args={})
    ctx = context(args)
    args[:question] ||= ctx.question
    ctx.assessment_template.assessment_template_questions.create!(args)
  end

  def assessment_response(student, args={})
    ctx = context(args)
    is_completed = args.delete(:completed)

    ctx.assessment.assessment_responses.create!(:student_id => student.id).tap do |ar|
      ar.reset_responses!
      ar.start!
      ar.complete! if is_completed
    end
  end

  def release_assessment_response!(args={})
    ctx = context(args)
    raise "assessment_response not set" if ctx.assessment_response.nil?
    ctx.assessment_response.update_attributes!(released: AssessmentResponse::ReleasedStates::RELEASED)
  end

  def find_or_create_assessment_template_by_title(title)
    AssessmentTemplate.find_by_title(title) || self.assessment_template(:title => title)
  end
  
  def assessment(args={})
    ctx = context(args)

    args[:assessment_template] ||= ctx.assessment_template
    args[:course] ||= ctx.course

    args.reverse_merge!(available: true)
    Fabricate(:assessment, args)
  end
  
  def course(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization
    args[:educators] ||= [ctx.user]
    args[:schools] ||= [ctx.school]

    Fabricate(:course, args)
  end

  def course_group(args={})
    ctx = context(args)
    Fabricate(:course_group, args.reverse_merge!(organization: ctx.organization))
  end
  
  def standard(args={})
    ctx = context(args)
    Fabricate(:standard, args.reverse_merge!(parent: ctx.organization.standards.first))
  end
  
  def organization(args={})
    Fabricate(:organization, args)
  end

  def shared_assessment_template(args={})
    ctx = context(args)
    ctx.assessment_template = Fabricate(:assessment_template, args.reverse_merge!(user: ctx.user))
    ctx.assessment_template.tag_list = ctx.organization.tag_list
    ctx.assessment_template.save!
    return ctx.assessment_template
  end

  def find_or_create_student_by_name(name, args={})
    my_student = Student.find_by_name(name)
    return my_student if my_student
    student(args.merge(:first_name => name))
  end

  def find_or_create_course_by_title(title, args={})
    my_course =  Course.find_by_title(title)
    return my_course if my_course
    course(args.merge(:title => title))
  end

  def create_naked_template(args={})
    ctx = context(args)
    ctx.assessment_template = assessment_template(args.merge(context: ctx))
  end
  
  def create_and_set_happy_day(args = {})
    ctx = context(args)
    create_naked_template(args.merge(context: ctx))
    ctx.assessment = assessment(assessment_template: ctx.assessment_template)
  end

  def representative_assessment_template(args={})
    ctx = context(args)
    ctx.assessment_template = assessment_template(context: ctx)

    add_question_of_type_to_assessment_template(context: ctx, question_type: :multiple_choice)
    add_question_of_type_to_assessment_template(context: ctx, question_type: :short_answer)
    add_question_of_type_to_assessment_template(context: ctx, question_type: :matching)
    add_question_of_type_to_assessment_template(context: ctx, question_type: :drag_and_drop_with_snap)

    add_question_of_type_to_assessment_template(context: ctx, question_type: :essay, rubric: nil)
    add_question_of_type_to_assessment_template(context: ctx, question_type: :essay, rubric: (args[:rubric] or rubric(context: ctx)))

    ctx.assessment_template
  end

  def add_question_of_type_to_assessment_template(args={})
    question_types_with_answers = [
      :drag_and_drop_with_snap,
      :matching,
      :multiple_choice,
      :short_answer,
    ]
    ctx = context(args)

    question_type = args[:question_type] || :multiple_choice

    fabricator = "#{question_type}_question"
    if question_types_with_answers.include?(question_type)
      fabricator = "#{fabricator}_with_answers"
    end

    question_args = args.slice(:description)
    question = Fabricate(fabricator.to_sym, question_args)
    standard = args.delete(:standard)
    points = args.delete(:points)
    question.standards << standard if standard

    # create the answer
    Fabricate("#{question_type}_answer".to_sym, :question => question)
    Fabricate("assessment_template_#{question_type}_question".to_sym,
              assessment_template: ctx.assessment_template, question: question,
              points: points,
              position: ctx.assessment_template.questions.count)

    if question.can_have_rubric? and args[:rubric]
      question.rubric = args[:rubric]
    end
  end

  def add_question_to_assessment_template(args={})
    ctx = context(args)
    add_question_of_type_to_assessment_template(args.reverse_merge(context: ctx, question_type: :multiple_choice))
  end

  def students_take_assessment(args={})
    whos = context(args)
    skip_scoring = args.delete(:skip_scoring)
    passed = args.delete(:passed)
    students = args.delete(:students) || whos.students
    assessment = args.delete(:assessment) || whos.assessment

    students.map do |student|
      notes = Faker::Lorem.sentences(2).join(" ")
      assessment_response = Fabricate(:completed_assessment_response, assessment: assessment, student: student, notes: notes)

      assessment.assessment_template_questions.each do |question|
        question.type.underscore =~ /(.*)_question/
        question_type = $1
        question_args = {}
        if question_type == "multiple_choice" || question_type == "true_false"
          answer = question.answers.detect { |answer| answer.correct }
          question_args[:answer_id] = answer.id
        elsif question_type == "short_answer"
          answer = question.answers.find { |answer| answer.correct }
          question_args[:body] = answer.body
        elsif question_type == "matching"
          question_args[:matches] = {}
        elsif question_type == "drag_and_drop_with_snap"
          question_args[:matches] = {}
        elsif question_type == "essay"
          question_args[:body] = Faker::Lorem.paragraph
          question_args[:points] = rand(question.points + 1) unless skip_scoring
        else
          puts "couldn't answer question type #{question.type}"
        end
        question_args[:points] ||= 0 unless skip_scoring

        question_args[:points] = question.points if passed
        type = passed ? "passed_#{question_type}_response" : "finished_#{question_type}_response"
        r = Fabricate(type.to_sym, question_args.merge(assessment_template_question: question, assessment_response: assessment_response, notes: Faker::Lorem.sentence, correct: passed == true)) 
      end

      assessment_response.complete!
      assessment_response
    end
  end

  def question(args={})
    ctx = context(args)
    with_answers = args.delete :with_answers
    QuestionManager.build!( args.reverse_merge(organization: ctx.organization, user: ctx.user, type: :multiple_choice)).tap do |question|
      if with_answers != false
        Fabricate(:multiple_choice_answer, :question => question, :body => "0", :correct => true)
        Fabricate(:multiple_choice_answer, :question => question, :body => "1", :correct => false)
      end
    end
  end

  def answer(args={})
    ctx = context(args)
    ctx.question.answers.create!(args)
  end

  def school(args={})
    ctx = context(args)
    args[:organization] ||= ctx.organization 
    Fabricate(:school, args)
  end

  def school_name(args={})
    ctx = context(args)
    Fabricate(:school_name, args)
  end

  def add_user_to_school(args={})
    ctx = context(args)
    args[:school] ||= ctx.school 
    args[:user] ||= ctx.user

    args[:user].schools << args[:school]
  end

  def add_course_to_school(args={})
    ctx = context(args)
    args[:school] ||= ctx.school 
    args[:course] ||= ctx.course

    args[:school].courses << args[:course]
  end

  private
  def context(args)
    # +++++++++++++++++++++++++++ I DELETE STUFF!!!!!!!!!!!! ++++++++++++
    # +++++++++++++++++++++++++++ I DELETE STUFF!!!!!!!!!!!! ++++++++++++
    # +++++++++++++++++++++++++++ I DELETE STUFF!!!!!!!!!!!! ++++++++++++
    # +++++++++++++++++++++++++++ I DELETE STUFF!!!!!!!!!!!! ++++++++++++
    # +++++++++++++++++++++++++++ I DELETE STUFF!!!!!!!!!!!! ++++++++++++
    context = args.delete(:context)
    context || @my
  end
end

class My
  attr_writer :iris_config, :question, :user, :assessment_response, :assessment_template,
    :assessment, :course, :course_group, :assessment_template_question, :organization,
    :standard, :program, :student, :educator, :rubric, :answer, :historical_assessment,
    :school, :role

  def assessment_template_question
    raise "assessment template question not set" unless @assessment_template_question
    return @assessment_template_question
  end

  def user
    raise "user not set" unless @user
    return @user
  end

  def school
    raise "school not set" unless @school
    return @school
  end

  def iris_config
    raise "iris config not set" unless @iris_config
    return @iris_config
  end

  def assessment_template
    raise "assessment template not set" unless @assessment_template
    return @assessment_template
  end

  def assessment
    raise "assessment not set" unless @assessment
    return @assessment
  end

  def course
    raise "course not set" unless @course
    return @course
  end

  def course_group
    raise "course group not set" unless @course_group
    return @course_group
  end

  def organization
    raise "organization not set" unless @organization
    return @organization
  end
 
  def organization?
    return @organization.present?
  end

  def assessment_response
    raise "organization not set" unless @organization
    return @assessment_response
  end
  
  def standard
    raise "standard not set" unless @standard
    return @standard
  end

  def question
    raise "question not set" unless @question
    return @question
  end

  def answer
    raise "answer not set" unless @answer
    return @answer
  end
  
  def program
    raise "program not set" unless @program
    return @program
  end

  def student
    raise "student not set" unless @student
    return @student
  end

  def educator
    raise "educator not set" unless @educator
    return @educator
  end

  def rubric
    raise "rubric not set" unless @rubric
    return @rubric
  end

  def role
    raise "role not set" unless @role
    return @role
  end

  def organization_with_code(org_code)
    organization = @organizations.select { |org| org.code == org_code }.first
    raise "organization with code [#{org_code}] not in organizations list" unless organization
    return organization
  end

  def historical_assessment
    raise "historical_assessment not set" unless @historical_assessment
    return @historical_assessment
  end

  def rubric_components
    @rubric_components ||= []
  end
  
  def students
    @students ||= []
  end

  def educators
    @educators ||= []
  end

  def courses
    @courses ||= []
  end

  def course_groups
    @course_groups ||= []
  end

  def assessment_responses
    @assessment_responses ||= []
  end

  def school_names
    @school_names ||= []
  end

  def assessment_template_questions
    @assessment_template_questions ||= []
  end

  def historical_assessment_results
    @historical_assessment_results ||= []
  end

  def schools
    @schools ||= []
  end

  def organizations
    @organizations ||= []
  end
end
