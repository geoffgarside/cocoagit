//
//  GITTree.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//
//  The Git Tree object is slightly complicated in its storage.
//  While tools such as git-ls-tree will output content such as
//  
//      $ git ls-tree a4738075cde81ca0aee0fb3602c506fd49f8c020
//      100644 blob bed4001738fa8dad666d669867afaf9f2c2b8c6a .gitignore
//      040000 tree b890976af5489b72ff39cb9640744d965214337b CocoaGit.xcodeproj
//      100644 blob aa99f9f0e9db15320a52576dae04c13e10c1b3cc CocoaGit_Prefix.pch
//      040000 tree ab5cea4809150a9c93a7f0de4137c83ff141b0bc English.lproj
//      100644 blob 421b03c7c48b987452a05f02b1bdf73fff93f3b9 GITBlob.h
//      100644 blob 8fe560bff9f311c3ec985073f8302b7e8adae4f1 GITBlob.m
//      100644 blob b177e0bcdb21464f749793fea4d2b65536618ad3 GITObject.h
//      100644 blob a8d68c6d18bb3aa0980a9af2d11745375e3e9af7 GITObject.m
//      100644 blob 612b7da52f2b817ae8cdcc59b1bcf0c589baafd2 Info.plist
//      100644 blob b94ad18edd2288b0a0fbbb819965503edbe9bea9 NSData+Compression.h
//      100644 blob 5ea05cb01e38c1391a06654332e7ac676122f076 NSData+Compression.m
//      100644 blob 67a5aef076f236e1a8b3bf7b69413f37273a3b9b NSData+Hashing.h
//      100644 blob d28319b3c4128a0051bba7153cdc359364309953 NSData+Hashing.m
//      100644 blob 488ed1ead925132b7c83b9a13e622928c3180c29 main.m
//  
//  the actual data contained within the .git/objects/a4738075cde81ca0aee0fb3602c506fd49f8c020
//  file is different. Firstly the type of each entry in the tree is not stored.
//  Secondly the SHA1 hash of the objects in the tree is packed. As an example
//  the .gitignore file listed above is listed as
//      
//      100644 .gitignore\000\276\324\000\0278\372\215\255fmf\230g\257\257\237,+\214j
//
//  within the tree object. This is actually three main fields. Two are 
//  delimited by the null byte. They are
// 
//      File Mode and name: 100644 .gitignore
//      SHA1 Object hash: \276\324\000\0278\372\215\255fmf\230g\257\257\237,+\214j
// 
//  The complicated part of parsing the tree file is properly separating the
//  entries in the tree. The splitting position can only be worked out by reading
//  up to the next null-byte then adding 20 for the packed SHA1.
//  
//  The next step in this is working out how best to decompress the SHA1 into
//  hex format for use in linking objects together.
//  It is worth noting that the packed SHA1 hash can be decoded in Ruby using
// 
//      packedHash.unpack('H40')
// 
//  so the packing method must be at least fairly standardized. The Ruby
//  String#unpack method with 'H' extracts hex nibbles from each character
//  with the most significant first.
//  
//  SHA1 Packing format:
//  For a normal human readable SHA1 hash we see it in ASCII format. But as
//  hex only uses 8 characters the ASCII 1 byte per char is a bit wasteful.
//  Instead we can store each hex character in 4 bits thereby halving the
//  space required to store the hash. To do this we use the first 4 bits of
//  the ASCII char for one HEX digit and the last 4 for the next.
//  
//  To expand this format we need to bitshift each char by 4 bits to get the
//  first HEX value and then mask the char with 0000 get the second HEX value.
// 

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

extern const NSString *kGITObjectTreeType;

@interface GITTree : GITObject {
    NSArray *entries;
}

#pragma mark -
#pragma mark Properties
@property(retain) NSArray* entries;

#pragma mark -
#pragma mark Instance Methods
- (NSString*)objectType;

@end
