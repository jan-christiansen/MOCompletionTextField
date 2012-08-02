//
//  TextFieldCell.m
//  ExampleApplication
//
//  Created by Jan Christiansen on 5/27/12.
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

#import "TextFieldCell.h"
#import "MOStringTrie.h"
#import "MOCompletionTextField.h"


@implementation TextFieldCell {

    IBOutlet MOCompletionTextField *_textField;
    Entry *_entry;
}


@synthesize delegate = _delegate;


#pragma mark - Setting and Getting Properties

- (Entry *)entry {

    return _entry;
}

- (void)setEntry:(Entry *)entry {

    _textField.text = entry.text;
    _entry = entry;
}

- (MOStringTrie *)completionStringTrie {

    return _textField.completionStringTrie;
}

- (void)setCompletionStringTrie:(MOStringTrie *)completionStringTrie {

    _textField.completionStringTrie = completionStringTrie;
}


#pragma mark - Initializing

- (id)init {

    UINib *cellNib = [UINib nibWithNibName:@"TextFieldCell" bundle:nil];

    NSArray *topLevelObjects = [cellNib instantiateWithOwner:self
                                                    options:nil];
    self = [topLevelObjects objectAtIndex:0];

    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.delegate = self;

    [_textField addTarget:self
                   action:@selector(didEndEdit:)
         forControlEvents:UIControlEventEditingDidEnd];
    _textField.resetOnEmptyInput = YES;

    return self;
}

- (void)didEndEdit:(id)sender {

    [sender resignFirstResponder];

    self.entry.text = _textField.text;

    [self.delegate textFieldCellDidEndEdit:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self.delegate textFieldCellDidBeginEditing:self];
}

// dummy method to keep reference to the class only used in xib
- (void)dummy {

    [MOCompletionTextField class];
}


@end
