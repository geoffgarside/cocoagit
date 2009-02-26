#!/usr/bin/env nush

;; command-line input
(set exit (NuBridgedFunction functionWithName:"exit" signature:"vi"))

(set argv ((NSProcessInfo processInfo) arguments))
(set progName (argv 1))
(set packfileName (argv 2))
(set sha1 (argv 3))

(unless (eq 4 (argv count))
        (puts "usage: #{progName} <pack file> <sha1>")
        (exit 1))

(load "Git")

(set packfile (GITPackFile packFileWithPath:packfileName))
(set packidx (packfile index))

(puts "pack version: #{(packfile version)}")
(puts "index version: #{(packidx version)}")

(set objOffset (packidx packOffsetForSha1:sha1 error:nil))     
(puts "sha1: #{sha1}, offset: #{objOffset}")

(set objData (packfile dataForObjectWithSha1:sha1))
(puts (objData hexdump))
(puts "obj size: #{(objData length)}")


