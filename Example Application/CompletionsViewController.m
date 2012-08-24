//
//  CompletionsViewController.m
//  ExampleApplication
//
//  Created by Jan Christiansen on 5/29/12.
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
#import "MOPair.h"
#import "NSArray+FunctionalStyle.h"
#import "CompletionsViewController.h"
#import "CompletionCell.h"


@implementation CompletionsViewController {

    // array of pairs of frequency and completion
    NSMutableArray *_completions;

    MOStringTrie *_stringTrie;
}


@synthesize delegate = _delegate;


- (id)initWithStringTrie:(MOStringTrie *)stringTrie {

    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

        _stringTrie = stringTrie;
        NSComparator comparator = ^(MOPair *pair1, MOPair *pair2) {
            NSString *string1 = pair1.second;
            NSString *string2 = pair2.second;
            return [string1 compare:string2];
        };
        _completions = [[[_stringTrie allObjects]
                         sortedArrayUsingComparator:comparator]
                            mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // set title
    self.title = @"List of Completions";

    // add buton
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = backButton;
}

- (void)cancel {

    [self.delegate modalViewControllerDidCancel:self];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)__unused tableView
 numberOfRowsInSection:(NSInteger)__unused section {

    return (NSInteger) [_completions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"CompletionCell";
    CompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[CompletionCell alloc] init];
    }

    MOPair *pair = [_completions objectAtIndex:(NSUInteger) indexPath.row];

    cell.frequencyLabel.text = [NSString stringWithFormat:@"%@", pair.first];
    cell.completionLabel.text = pair.second;

    return cell;
}

- (NSString *)tableView:(UITableView *)__unused tableView
titleForFooterInSection:(NSInteger)__unused section {

    return @"List of previously entered entries and their frequency. An entry"
            " is deleted from the string trie that contains completions by"
            " swiping.";
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MOPair *pair = [_completions objectAtIndex:(NSUInteger) indexPath.row];
        [_stringTrie removeObjectForString:pair.second];
        [_completions removeObject:pair];
    }

    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString*)tableView:(UITableView *)__unused tableView
titleForHeaderInSection:(NSInteger)__unused section {

    return @"Completion                     Frequency";
}


@end
