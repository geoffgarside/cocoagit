#!/usr/bin/env nush

; Tests 2 files to see whether they contain the same set of lines
; even if the order of the lines is different.

;; command-line input
(set exit (NuBridgedFunction functionWithName:"exit" signature:"vi"))

(set argv ((NSProcessInfo processInfo) arguments))
(set file1 (argv 2))
(set file2 (argv 3))

(set contents1 (NSString stringWithContentsOfFile:file1))
(set lines1 ((contents1 chomp) componentsSeparatedByCharactersInSet:(NSCharacterSet newlineCharacterSet)))
(set contents2 (NSString stringWithContentsOfFile:file2))
(set lines2 ((contents2 chomp) componentsSeparatedByCharactersInSet:(NSCharacterSet newlineCharacterSet)))

(set diffs (NSMutableSet new))
(lines1 each:(do (line)
     (unless (lines2 containsObject:line)
          (diffs addObject:line))))

(puts ("#{(diffs count)} lines differ"))
;(puts (diffs list))
