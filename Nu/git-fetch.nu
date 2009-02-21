#!/usr/bin/env nush
; CocoaGit
;
; git-fetch.nu
; A very basic git-fetch client that uses the CocoaGit API.
; It currently only support a 'clone'-style operation, in that it
; download all refs available on the remote end, and writes out the
; PACK file containing all of the objects.
;
;  Created by Brian Chapados on 2/12/09.
;  Copyright 2009 Brian Chapados. All rights reserved.
;

;; command-line input
(set exit (NuBridgedFunction functionWithName:"exit" signature:"vi"))

(set argv ((NSProcessInfo processInfo) arguments))
(set progName (argv 1))
(set urlString (argv lastObject))

(unless (eq 3 (argv count))
        (puts "usage: #{progName} git://<host>/path/to/repo.git")
        (puts "       #{progName} ssh://<user>@<host>/path/to/repo.git")
        (exit 1))

(set url (NSURL URLWithString:urlString))

;; script

(load "Git")

; (set url (NSURL URLWithString:"git://github.com/geoffgarside/cocoagit"))

(function get_transport (url)
     (case (url scheme)
           ("git" ((GITTransport alloc) initWithURL:url repo:nil))
           ("ssh" ((GITSshTransport alloc) initWithURL:url repo:nil))))


(set transport (get_transport url))

(transport connect)
(puts "connected")
(transport startFetch)
(puts "sent fetch")
(set packets (transport readPackets))
(puts "read packets")

; (transport disconnect)

; (packets each:(do (p) (puts (p hexdump))))

(set refs
     (packets map:
              (do (p)
                  (set ps ((NSString alloc) initWithData:p encoding:(NSString defaultCStringEncoding)))
                  (GITRef refWithPacketLine:ps))))

(refs each:(do (r) (puts "#{(r name)} => #{(r sha1)}")))

; (puts "local refs")
; (set r ((GITRepo alloc) initWithRoot:"."))
; (set refs (r refs))
; (refs each:(do (ref) (puts "#{(ref \"name\")} => #{(ref \"sha\")}")))

(set need_refs (refs select:(do (r) (not ((r name) hasSuffix:"^{}")))))

(need_refs eachWithIndex:
     (do (r i)
         (if (eq 0 i)
             (set ps ("want #{(r sha1)} no-progress ofs-delta\n"))
             (else
                  (set ps "want #{(r sha1)}\n")))
         (set p (transport packetWithString:ps))
         (transport writePacket:p)))

(transport packetFlush)
(transport writePacket:(transport packetWithString:"done\n"))
(puts "sent WANTs")

; get NAK response from server
(set nak (transport readPacket))
(puts "got nak: #{(nak hexdump)}")

(puts "receiving packfile")
(set packdata (transport readPackStream))

; readPackObjects is broken from ofs-delta
;(set packdata (transport readPackObjects))

(packdata writeToFile:"fetched-packfile.pack" atomically:YES)
; 
(set e (NuReference new))
(set packfile ((GITPackFile alloc) initWithData:packdata error:e))

(puts "packfile info:")
(puts "objects: #{(packfile numberOfObjects)}")
