Feature: A creator manages rubrics
  Background:
    Given I am a creator
     When I login

  Scenario: Creator can view their rubric
    Given I have a rubric
     When I view the rubrics
     Then I should see my rubric

  Scenario: Creator can change a rubric title
    Given I have a rubric
      And I edit my rubric

     When I change the rubric title to "Monkey Steals the Peach"
     Then I should see "Monkey Steals the Peach" as the rubric title

  Scenario: Creator can view existing components on the rubric
    Given I have a rubric with components
     When I edit my rubric
     Then I should see the rubric components

  Scenario: Creator can update rubric component weights
    Given I have a rubric with components
     When I edit my rubric
      And I update my component weights
     Then I should see my new weights on the given components

     When I edit my rubric
      And I evenly distribute my component weights
     Then I should see my component weighted equally
    
  Scenario: Creator can add new components to the rubric
    Given I am creating a rubric component
    When I add a rubric component indicator
      And I add 5 descriptors
      And I save the component
     Then I should see my rubric has a new component indicator

  Scenario: Creator can create a new rubric
    Given I view the rubrics
     When I add a new rubric
     Then I should see my rubric

  Scenario: Creator can delete a rubric
    Given I have a rubric
      And I edit my rubric
     When I delete my rubric
     Then I should see my rubric has been deleted

  Scenario: Creator cannot modify Rubric Components of a locked rubric
    Given I have a locked rubric
     When I edit my rubric
     Then I should not be able to edit the rubric components

