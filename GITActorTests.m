//
//  GITActorTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITActorTests.h"
#import "GITActor.h"

@implementation GITActorTests

- (void)testShouldInitWithName
{
    GITActor * actor = [[GITActor alloc] initWithName:@"Enoch Root"];
    STAssertEqualObjects(actor.name, @"Enoch Root", nil);
}
- (void)testShouldInitWithNameAndEmail
{
    GITActor * actor = [[GITActor alloc] initWithName:@"Enoch Root" andEmail:@"root@example.com"];
    
    STAssertEqualObjects(actor.name, @"Enoch Root", nil);
    STAssertEqualObjects(actor.email, @"root@example.com", nil);
}
- (void)testShouldFormatNameAndEmailInDescription
{
    GITActor * actor = [[GITActor alloc] initWithName:@"Enoch Root" andEmail:@"root@example.com"];
    
    STAssertEqualObjects([actor description], @"Enoch Root <root@example.com>", nil);
}

@end
