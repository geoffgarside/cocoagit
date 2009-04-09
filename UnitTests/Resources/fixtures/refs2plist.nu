#!/usr/bin/env nush

(set showRefs ((NSString stringWithShellCommand:"git show-ref --head") chomp))
(set refStrings (showRefs componentsSeparatedByCharactersInSet:
                     (NSCharacterSet newlineCharacterSet)))

(set refInfo (dict))

(refStrings each:
     (do (line)
         (set info (line componentsSeparatedByCharactersInSet:
                         (NSCharacterSet whitespaceCharacterSet)))
         (set sha1 (info 0))
         (set refName (info 1))
         
         (set chunks (/\// splitString:refName))
         (unless (> (chunks count) 2) (continue))
         (unless ((chunks 0) isEqual:"refs") (continue))

         (set group (chunks 1))
         ; (set nameLength (- (chunks count) 2))
         ;  (set nameList (chunks subarrayWithRange:(list 2 nameLength)))
         ;  (set shortName (nameList componentsJoinedByString:"/"))
         (set name refName)
         
         (unless (refInfo group)
                 (refInfo setValue:(dict) forKey:group))
         (set groupInfo (refInfo group))
         (unless (groupInfo name)
                 (groupInfo setValue:sha1 forKey:name)
                 (refInfo setValue:groupInfo forKey:group))))

(refInfo writeToFile:"refFixtures.plist" atomically:NO)

