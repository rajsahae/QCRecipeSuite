Feature: Analyzer compares cycles from NanoStandard between two versions

  As a Software Quality engineer
  I want to compare the average and standard deviation on the NanoStandard
  between two versions 
  So that I can confirm the software upgrade did not affect the metrology tool

  The user calls the Analyzer with two directories as command line arguments.
  The analyzer pulls the NanoStandard database text files from the directories,
  parses it, calculates the average and standard deviation for each group and
  film strategy, compares it, and returns a message to the user about whether
  or not the test has passed or failed.

  Scenario: Comparison of identical NanoStandard N2000 DB files
    Given two database csv files "data/cucumber/original.csv" and "data/cucumber/copy.csv"
    When compared to each other
    Then the analyzer should print "PASSED"

  Scenario: Comparison of different NanoStandard N2000 DB files
    Given two database csv files "data/cucumber/original.csv" and "data/cucumber/bad.csv"
    When compared to each other
    Then the analyzer should print "FAILED"
