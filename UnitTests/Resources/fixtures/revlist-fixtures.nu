#!/usr/bin/env nush
#
# Generate fixture .plist files containing arrays
# of commit-sha1 orders output from git-rev-list commands
#
# copyright 2009, Brian Chapados
#

# Background:
# The revwalk-test branch in the 'dot_git' bare repo contains
# a commit tree that will produce uniquely ordered output for
# the default, --date-order and --topo-order options to git-rev-list
#

(set repoDir "../dot_git")
(set branch "revwalk-test")
(set revList "git-rev-list")

(set optionsMap (dict "default" ""
                      "date" "--date-order"
                      "topo" "--topo-order"))

(set commitLists (dict))
(optionsMap each:
     (do (name options)
         (set output
              ((NSString stringWithShellCommand:"cd #{repoDir} && #{revList} #{options} #{branch}") chomp))
         (commitLists setValue:(/\n/ splitString:output) forKey:name)))

(puts (commitLists description))
;(commitLists writeToFile:"../fixtures/revListFixtures.plist" atomically:YES)
(commitLists writeToFile:"revListFixtures.plist" atomically:YES)
