//
//  GITGraph.h
//  CocoaGit
//
//  Created by chapbr on 4/23/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITObjectNode;
@class GITCommit;
@interface GITGraph : NSObject {
    NSMutableDictionary *nodes;
}
- (NSUInteger) countOfNodes;
//- (NSUInteger) countOfEdges;

- (BOOL) hasNode:(GITObjectNode *)aNode;
- (GITObjectNode *) nodeWithKey:(NSString *)aKey;

- (void) addNode:(GITObjectNode *)newNode;
- (void) removeNode:(GITObjectNode *)aNode;
- (void) addEdgeFromNode:(GITObjectNode *)sourceNode toNode:(GITObjectNode *)targetNode;
//- (void) removeEdgeFromNode:(GITObjectNode *)sourceNode toNode:(GITObjectNode *)targetNode;

- (void) buildGraphWithStartingCommit:(GITCommit *)commit;
- (NSArray *) nodesSortedByDate;
- (NSArray *) nodesSortedByTopology:(BOOL)useLifo;

//- (void) addCommit:(GITCommit *)gitCommit;
//- (void) removeCommit:(GITCommit *)gitCommit;
//- (void) addCommit:(GITCommit *)gitCommit includeTree:(BOOL)includeTree;
//- (void) removeCommit:(GITCommit *)gitCommit includeTree:(BOOL)includeTree;
@end