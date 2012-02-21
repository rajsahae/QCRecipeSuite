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
    Then the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET PASSED"

  Scenario: Comparison of different NanoStandard N2000 DB files
    Given two database csv files "data/cucumber/original.csv" and "data/cucumber/bad.csv"
    When compared to each other
    Then the analyzer should print "FAILED - SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET FAILED"

  Scenario: Comparison of good DB files with 2 stage groups
    Given two database csv files "data/cucumber/2groups.csv" and "data/cucumber/2groups-good.csv"
    When compared to each other
    Then the analyzer should print "PASSED - SQC Acq-SR OCD VIS:4X Pad5 Vis:SQC NSTD:# 24"
    And the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET PASSED"

  Scenario: Comparison of bad DB files with 2 stage groups
    Given two database csv files "data/cucumber/2groups.csv" and "data/cucumber/2groups-bad.csv"
    When compared to each other
    Then the analyzer should print "FAILED - SQC Acq-SR OCD VIS:4X Pad5 Vis:SQC NSTD:# 24"
    And the analyzer should print "FAILED - SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET FAILED"

  Scenario: Comparison of one good DB file and one bad one, both with 2 stage groups
    Given two database csv files "data/cucumber/2groups.csv" and "data/cucumber/2groups-one-bad.csv"
    When compared to each other
    Then the analyzer should print "PASSED - SQC Acq-SR OCD VIS:4X Pad5 Vis:SQC NSTD:# 24"
    And the analyzer should print "FAILED - SQC Acq-SR OCD Short2 FX:4X Pad6 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET FAILED"

  Scenario: Comparison of DB files with two matching groups and 2 non-matching groups interleaved
    Given two database csv files "data/cucumber/4groups-interleaved-1_no-summary.csv" and "data/cucumber/4groups-interleaved-2_no-summary.csv"
    When compared to each other
    Then the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad0 FX:SQC NSTD:# 24"
    And the analyzer should print "FAILED - SQC Acq-SR OCD Short2 FX:4X Pad0 SCF:SQC NSTD:# 24"
    And the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad0 Vis:SQC NSTD:# 24"
    And the analyzer should print "FAILED - SQC Acq-SR OCD Short2 FX:4X Pad1 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET FAILED"

  Scenario: Comparison of DB files with one file having groups the other file doesn't
    Given two database csv files "data/cucumber/4groups-interleaved-1_no-summary.csv" and "data/cucumber/3groups_no-summary.csv"
    When compared to each other
    Then the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad0 FX:SQC NSTD:# 24"
    And the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad0 SCF:SQC NSTD:# 24"
    And the analyzer should print "PASSED - SQC Acq-SR OCD Short2 FX:4X Pad0 Vis:SQC NSTD:# 24"
    And the analyzer should print "SKIPPED - SQC Acq-SR OCD Short2 FX:4X Pad1 FX:SQC NSTD:# 24"
    And the analyzer should print "FULL SET PASSED"

