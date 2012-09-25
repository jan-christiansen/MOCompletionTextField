//
//  MOWordPicker.m
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

#import <QuartzCore/QuartzCore.h>
#import "MOWordPicker.h"
#import "MOWordLabel.h"


@interface MOWordPicker () {

    NSArray *_words;
}

@end


@implementation MOWordPicker


#pragma mark - Constants

// margin between boungs of view and words
static const float kMargin = 8;

// distance between two horizontally subsequent words
static const float kWidthInnerMargin = 4;

// distance between two rows of words
static const float kHeightInnerMargin = 2;

// font size used to display words
static const float kFontSize = 14;


#pragma mark - Initializing

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHue:0
                                          saturation:0
                                          brightness:0
                                               alpha:0.1];
    }
    return self;
}


#pragma mark - Setting and Getting Properties

// when the array of words is altered the view is updated to present these words
- (void)setWords:(NSArray *)words {

    if (_words != words) {
        _words = words;
        [self updateView];
    }
}

- (NSArray *)words {

    return _words;
}


#pragma mark - Gesture Handling

// wordpicker that only handle taps on words
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)__unused event {

    BOOL hitsALabel = NO;
    for (UIView *subview in self.subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            hitsALabel = YES;
        }
    }
    return hitsALabel;
}

// delegate is invoked if user taps on word
- (void)handleTap:(UITapGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateEnded) {

        UILabel *hitLabel = (UILabel *) recognizer.view;
        [self.delegate wordPicker:self didPickWord:hitLabel.text];
    }
}


#pragma mark - View Update

- (void)updateView {

    CGPoint nextHorizontalOrigin = CGPointMake(kMargin, kMargin);

    // remove all labels
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }

    // add labels
    for (NSString *word in _words) {

        // add label
        MOWordLabel *wordLabel = [[MOWordLabel alloc] initWithFrame:CGRectZero];
        wordLabel.text = word;
        wordLabel.font = [UIFont systemFontOfSize:kFontSize];
        [wordLabel sizeToFit];

        CGRect labelFrame = wordLabel.frame;
        CGPoint nextVerticalOrigin;

        if (nextHorizontalOrigin.x + labelFrame.size.width + 10 > self.bounds.size.width) {
            nextVerticalOrigin = CGPointMake(kMargin, nextHorizontalOrigin.y + labelFrame.size.height + kMargin);
        } else {
            nextVerticalOrigin = nextHorizontalOrigin;
        }

        if (nextVerticalOrigin.y + labelFrame.size.height < self.bounds.size.height) {

            labelFrame.origin.x = nextVerticalOrigin.x;
            labelFrame.origin.y = nextVerticalOrigin.y;

            nextHorizontalOrigin = CGPointMake(labelFrame.origin.x + labelFrame.size.width + kMargin,
                                               labelFrame.origin.y);

            // add label
            wordLabel.frame = labelFrame;
            [self addSubview:wordLabel];

            // add tap gesture recognizer
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(handleTap:)];
            wordLabel.userInteractionEnabled = YES;
            [wordLabel addGestureRecognizer:tapGestureRecognizer];
        }
    }
}


@end
