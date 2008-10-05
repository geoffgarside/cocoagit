//
//  GITActorTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITActor;
@interface GITActorTests : SenTestCase {
    
}

- (void)testShouldInitWithName;
- (void)testShouldInitWithNameAndEmail;
- (void)testShouldFormatNameAndEmailInDescription;

@end
