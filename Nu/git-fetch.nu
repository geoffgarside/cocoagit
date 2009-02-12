#!/usr/bin/env nush

;; command-line input
(set exit (NuBridgedFunction functionWithName:"exit" signature:"vi"))

(set argv ((NSProcessInfo processInfo) arguments))
(set progName (argv 1))
(set urlString (argv lastObject))

(unless (urlString hasPrefix:"git://")
  (puts "usage: #{progName} git://<host>/path/to/repo.git")
  (exit 1))

(set url (NSURL URLWithString:urlString))

;; script

(load "Git")

; (set url (NSURL URLWithString:"git://github.com/geoffgarside/cocoagit"))

(set transport ((GITTransport alloc) initWithURL:url repo:nil))

(transport connect)
(puts "connected")
(transport startFetch)
(puts "sent fetch")
(set packets (transport readPackets))
(puts "read packets")
(transport disconnect)

; (packets each:(do (p) (puts (p hexdump))))

(packets each:(do (p)
  (set ps ((NSString alloc) initWithData:p encoding:(NSString defaultCStringEncoding)))
  (set ref (GITRef refWithPacketLine:ps))
  (puts "#{(ref name)} => #{(ref sha1)}")))

; (puts "local refs")
; (set r ((GITRepo alloc) initWithRoot:"."))
; (set refs (r refs))
; (refs each:(do (ref) (puts "#{(ref \"name\")} => #{(ref \"sha\")}")))
