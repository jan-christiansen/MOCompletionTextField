//
//  MOCompletionTextField.m
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

#import "MOCompletionTextField.h"
#import "MOWordPicker.h"
#import "MOStringTrie.h"
#import "MOPair.h"
#import "NSArray+FunctionalStyle.h"


@interface MOCompletionTextField ()


/**
 *  Utility Method used in Initialization
 */
- (void)initialize;


@end


@implementation MOCompletionTextField {

    MOWordPicker *_wordPicker;

    // we remeber the previous text to reset it if resetOnEmptyInput is set
    NSString *_previousText;
}


@synthesize completionStringTrie = _completionStringTrie;
@synthesize completionEnumerationStyle = _completionEnumerationStyle;
@synthesize resetOnEmptyInput = _resetOnEmptyInput;


#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {

    // default values for enumeration style and string trie
    _completionEnumerationStyle = MOCompletionEnumerationFrequency;
    _completionStringTrie = [[MOStringTrie alloc] init];

    // initialize word picker
    CGRect wordPickerFrame = CGRectMake(0, 0, 320, 100);
    _wordPicker = [[MOWordPicker alloc] initWithFrame:wordPickerFrame];
    _wordPicker.delegate = self;
    self.inputAccessoryView = _wordPicker;

    // handling events of text field
    [self addTarget:self 
             action:@selector(handleBeginEdit)
   forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self
             action:@selector(handleChange)
   forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self
             action:@selector(handleEndEdit) 
   forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self
             action:@selector(resignFirstResponder) 
   forControlEvents:UIControlEventEditingDidEndOnExit];
}


#pragma mark - Setting and Getting Properties

// these methods are reimplemented to save the previously used text
- (void)setText:(NSString *)text {

    _previousText = super.text;
    super.text = text;
}

- (NSString *)text {

    return super.text;
}


#pragma mark - Handling Events of UITextField

- (void)handleBeginEdit {

    // user started editing text field, display completions for current text
    [self displayCompletionsForWord:self.text];
}

- (void)handleChange {

    // text in text field changed, display completions for changed text
    [self displayCompletionsForWord:self.text];
}

- (void)displayCompletionsForWord:(NSString *)word {

    // array of pairs
    // first component contains frequency, second component contains completion
    NSArray *pairs = [_completionStringTrie objectsForString:word];
    NSComparator comparator;

    if (self.completionEnumerationStyle == MOCompletionEnumerationLexicographical) {
        // lexigraphical ordering
        comparator = ^(MOPair *pair1, MOPair *pair2) {
            NSString *string1 = pair1.second;
            NSString *string2 = pair2.second;
            return [string1 compare:string2];
        };
    } else {
        // ordered by frequency, highest frequency comes first
        comparator = ^(MOPair *pair1, MOPair *pair2) {
            NSNumber *number1 = pair1.first;
            NSNumber *number2 = pair2.first;
            switch ([number1 compare:number2]) {
                // if frequencies are identical we order them lexicographical
                case NSOrderedSame: {
                    NSString *string1 = pair1.second;
                    NSString *string2 = pair2.second;
                    return [string1 compare:string2];
                }
                case NSOrderedAscending:
                    return (NSComparisonResult) NSOrderedDescending;
                case NSOrderedDescending:
                    return (NSComparisonResult) NSOrderedAscending;
            }
        };
    }

    NSArray *sortedPairs = [pairs sortedArrayUsingComparator:comparator];
    _wordPicker.words = [sortedPairs map:^(MOPair *pair) {
        return pair.second;
    }];;
}

- (void)handleEndEdit {

    if (self.text != _previousText) {
        if (self.resetOnEmptyInput && [self.text isEqualToString:@""]) {

            self.text = _previousText;
        } else {

            // editing text ended either by selecting another text field
            // or pressing done
            MOPair *pair = [_completionStringTrie objectForString:self.text];

            if (pair) {
                NSNumber *frequency = pair.first;
                pair.first = @(frequency.intValue+1);
            } else {
                MOPair *initialPair = [[MOPair alloc] 
                                       initWithFirst:@1
                                       second:self.text];
                [_completionStringTrie setObject:initialPair forString:self.text];
            }
        }
    }
}


#pragma mark - CompletionsViewDelegate Methods

- (void)wordPicker:(MOWordPicker *)__unused wordPicker
       didPickWord:(NSString *)word {

    // user selected a completion

    // set text to completion
    self.text = word;

    // dismiss keyboard
    [self resignFirstResponder];
}


@end
