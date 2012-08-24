//
//  TextFieldTableViewController.m
//  ExampleApplication
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

#import <QuartzCore/QuartzCore.h>
#import "TextFieldTableViewController.h"
#import "MOStringTrie.h"
#import "MOCompletionTextField.h"
#import "TextFieldCell.h"
#import "CompletionsViewController.h"
#import "Entry.h"


static NSString *kCompletionsFileName = @"completions.trie";


@interface TextFieldTableViewController ()

- (void)loadCompletionsTrie;

- (void)saveCompletionsTrie;

@end


@implementation TextFieldTableViewController {

#pragma mark - Model

    NSMutableArray *_entries;

    MOStringTrie *_itemCompletionTrie;

    NSIndexPath *currentlyEdited;

#pragma mark - Compatibility

    BOOL _respondsToPresentViewController;
    BOOL _respondsToDismissViewController;
}


@synthesize tableView = _tableView;


#pragma mark - Initialization

- (id)init {

    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];

        [self registerForKeyboardNotifications];

        // remember these so we don't have to query them every time
        _respondsToPresentViewController = [self respondsToSelector:@selector(presentViewController:animated:completion:)];
        _respondsToDismissViewController = [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)];

        _entries = [NSMutableArray arrayWithObject:[[Entry alloc] initWithText:@""]];

        [self loadCompletionsTrie];
    }
    return self;
}

- (void)registerForKeyboardNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {

    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
}

- (void)keyboardWillBeHidden:(NSNotification*)__unused aNotification {

    self.tableView.contentInset = UIEdgeInsetsZero;
}


#pragma mark - UIViewController Methods

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.title = @"MOCompletionTextFields";

    self.navigationController.toolbarHidden = NO;

    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil
                              action:nil];

    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Completions"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(presentCompletionsViewController)];

    self.toolbarItems = [NSArray arrayWithObjects:space, button, nil];
}

- (void)presentCompletionsViewController {

    CompletionsViewController *completionsController = [[CompletionsViewController alloc] 
                                                        initWithStringTrie:_itemCompletionTrie];
    completionsController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] 
                                                    initWithRootViewController:completionsController];

    if (_respondsToPresentViewController) {
        [self presentViewController:navigationController animated:YES completion:nil];
    } else {
        [self presentModalViewController:navigationController animated:YES];
    }
}

- (void)modalViewControllerDidCancel:(UIViewController *)__unused modalViewController {

    if (_respondsToDismissViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }

    // CompletionsViewController might have deleted completions therefore we
    // save the trie when the controller is dismissed
    [self saveCompletionsTrie];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return (UIInterfaceOrientationPortrait == interfaceOrientation);
}


#pragma mark - UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)__unused tableView
 numberOfRowsInSection:(NSInteger)__unused section {

    return (NSInteger) _entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"TextFieldCell";

    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TextFieldCell alloc] init];
        cell.delegate = self;
    }

    cell.completionStringTrie = _itemCompletionTrie;
    cell.entry = [_entries objectAtIndex:indexPath.row];

    return cell;
}

- (NSString*)tableView:(UITableView *)__unused tableView
titleForFooterInSection:(NSInteger)__unused section {

    return @"Each cell of this table contains a MOCompletionTextField. All"
            " of these fields share a common string trie that contains all"
            " previously entered entries. When the trie is altered it is"
            " written to disc and loaded on the next start.";
}


#pragma mark - TextFieldCellDelegate

- (void)textFieldCellDidBeginEditing:(TextFieldCell *)textFieldCell {

    // scroll table view such that edited cell is at the top
    NSIndexPath *textFieldCellIndexPath = [self.tableView indexPathForCell:textFieldCell];

    [self.tableView scrollToRowAtIndexPath:textFieldCellIndexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (void)textFieldCellDidEndEdit:(TextFieldCell *)__unused textFieldCell {

    Entry *firstItem = [_entries objectAtIndex:0];

    if (![firstItem.text isEqualToString:@""]) {
        // add new empty entry

        [_entries insertObject:[[Entry alloc] initWithText:@""] atIndex:0];
        NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:firstRow]
                              withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:firstRow]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }

    // write completion trie to file
    [self saveCompletionsTrie];
}


#pragma mark - Loading and Saving the Completion Trie

- (void)loadCompletionsTrie {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    // load item completion trie
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kCompletionsFileName];

    if ([fileManager fileExistsAtPath:filePath]) {
        _itemCompletionTrie = [[MOStringTrie alloc] initWithContentsOfFile:filePath];
    } else {
        _itemCompletionTrie = [[MOStringTrie alloc] init];
    }
}

- (void)saveCompletionsTrie {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    // save item completion trie
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kCompletionsFileName];

    [_itemCompletionTrie writeToFile:filePath];
}


@end
