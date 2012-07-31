//
//  MOStringTrie.m
//  MOCompletionTextField
//
//  Created by Jan Christiansen on 7/26/12.
//  Copyright (c) 2012, Monoid - Development and Consulting - Jan Christiansen
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials provided
//  with the distribution.
//
//  * Neither the name of Monoid - Development and Consulting - 
//  Jan Christiansen nor the names of other
//  contributors may be used to endorse or promote products derived
//  from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MOStringTrie.h"


@implementation MOStringTrie


@synthesize object = _object;
@synthesize stringTries = _stringTries;


#pragma mark - Class Methods

+ (id)stringTrieWithObject:object forString:key {

    return [[MOStringTrie alloc] initWithObject:object forString:key];
}


#pragma mark - Initialization

- (id)initWithObject:(id)object forString:(NSString *)key {

    self = [super init];
    if (self) {
        if ([key length] == 0) {
            _object = object;
        } else {
            MOStringTrie *nextStringTrie = [[MOStringTrie alloc]
                                            initWithObject:object
                                            forString:[key substringFromIndex:1]];
            NSString *firstKeyChar = [key substringToIndex:1];
            _stringTries = [NSMutableDictionary dictionaryWithObject:nextStringTrie
                                                              forKey:firstKeyChar];
        }
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)filePath {

    self = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return self;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)coder {

    _object = [coder decodeObjectForKey:@"_object"];
    _stringTries = [[NSMutableDictionary alloc] initWithCoder:coder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:_object forKey:@"_object"];
    [_stringTries encodeWithCoder:coder];
}


#pragma mark - Accessing Objects

- (id)objectForString:(NSString *)key {

    id result;
    if ([key length] == 0) {

        result = _object;
    } else {

        NSString *firstKeyChar = [key substringToIndex:1];

        MOStringTrie *nextStringTrie = [_stringTries objectForKey:firstKeyChar];
        if (nextStringTrie) {
            result = [nextStringTrie objectForString:[key substringFromIndex:1]];
        } else {
            result = nil;
        }
    }

    return result;
}

- (NSArray *)objectsForString:(NSString *)key {

    NSArray *result;
    if ([key length] == 0) {

        result = [self allObjects];
    } else {

        NSString *firstKeyChar = [key substringToIndex:1];

        MOStringTrie *nextStringTrie = [_stringTries objectForKey:firstKeyChar];
        if (nextStringTrie) {
            result = [nextStringTrie objectsForString:[key substringFromIndex:1]];
        } else {
            result = [NSArray array];
        }
    }

    return result;
}

- (NSArray *)allObjects {

    NSMutableArray *result = [NSMutableArray array];
    for (MOStringTrie *stringTrie in _stringTries.allValues) {
        [result addObjectsFromArray:[stringTrie allObjects]];
    }
    if (_object) {
        [result addObject:_object];
    }
    return result;
}


#pragma mark - Adding Objects

- (void)setObject:(id)object forString:(NSString *)key {

    if ([key length] == 0) {

        _object = object;
    } else {

        NSString *firstKeyChar = [key substringToIndex:1];
        NSString *restString = [key substringFromIndex:1];

        MOStringTrie *nextStringTrie = [_stringTries objectForKey:firstKeyChar];
        if (nextStringTrie) {
            [nextStringTrie setObject:object forString:restString];
        } else {
            nextStringTrie = [MOStringTrie stringTrieWithObject:object 
                                                    forString:restString];
            if (!_stringTries) {
                _stringTries = [NSMutableDictionary dictionary];
            }
            [_stringTries setObject:nextStringTrie forKey:firstKeyChar];
        }
    }
}


#pragma mark - Removing Objects

- (void)removeObjectForString:(NSString *)key {

    if ([key length] == 0) {
        
        _object = nil;
    } else {

        NSString *firstKeyChar = [key substringToIndex:1];
        NSString *restString = [key substringFromIndex:1];

        MOStringTrie *nextStringTrie = [_stringTries objectForKey:firstKeyChar];
        if (nextStringTrie) {
            [nextStringTrie removeObjectForString:restString];

            if (!nextStringTrie.object && [nextStringTrie.stringTries count] == 0) {
                [_stringTries removeObjectForKey:firstKeyChar];
            }
        }
    }
}


#pragma mark - Writing to a File

- (void)writeToFile:(NSString *)filePath {

    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}


@end
