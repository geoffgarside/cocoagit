#!/usr/bin/env nush
#
# pack-info.nu
#
# generate an XML property list file containing information
# about objects in the pack files used for testing.
#
# copyright 2009, Brian Chapados
#

#--- Add data below ---#

; these are valid for the delta-ref packfile
(set packFixtures
     '((rawBlob (sha1:"e83483aee3acd1ed7e268f524feaccefc20dd9e7"))
       (deltifiedBlob (sha1:"dad7275d1d9c17b81ffab9a61cfd48c940aaf994"))
       (deltifiedBlobXO (sha1:"da26259c7057cedc6552071f1fc51b430e01fab4"))
       (rawTree (sha1:"d00160399d71034078fd8ea531a6739f321b369b"))
       (deltifiedTree (sha1:"dc493b818cbbf489bf5e6dfa793fc991df4fc078"))
       (deltifiedTreeXO (sha1:"fac337c337d0dc53a61360daad8f18b632066460"))
       (firstObject (sha1:"85f6ab303f8f6601377ce2d8ebcf186c4b5d7d68"
                     offset:12))
       (lastNormalObject (sha1:"8c9db88c17479d4663658fd9321e095ea2c4a690"
                          offset:299902))
       (penultimateObject (sha1:"5cf8773ba4c007845873e3d8b23d406652a1f8c4"
                           offset:332809))
       (lastObject (sha1:"a01ba8491691058a072cbb4b12acce1d54801e22"
                    offset:332902))))

#--- Should not need to edit below this line ---

(function fixtures-dictionary (fixtures_description)
     (fixtures_description reduce:
          (do (d f)
              (set name (car f))
              (set info (car (cdr f)))
              (d setValue:(NSDictionary dictionaryWithList:info)
                 forKey:(name stringValue))
              d)
          from:(NSMutableDictionary new)))

(puts ((fixtures-dictionary packFixtures) description))
(if ((fixtures-dictionary packFixtures) writeToFile:"packFixtures.plist" atomically:NO)
    (then
         (puts "Generated packFixtures.plist"))
    (else
         (puts "ERROR: packFixtures.plist was not written")))
