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

    NSMutableArray *_words;
    MOWordLabel *draggedLabel;
    CGPoint dragStartCenter;
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

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}


#pragma mark - Setting and Getting Properties

- (void)setRemovableWords:(BOOL)removableWords {

    _removableWords = removableWords;

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

// when the array of words is altered the view is updated to present these words
- (void)setWords:(NSArray *)words {

    if (_words != words) {
        _words = words.mutableCopy;
        [self updateView];
    }
}


#pragma mark - Gesture Handling

- (MOWordLabel *)hitLabel:(UIGestureRecognizer *)recognizer {

    CGPoint hit = [recognizer locationInView:self];
    for (UIView *subview in self.subviews) {
        if (CGRectContainsPoint(CGRectInset(subview.frame, -5, -5), hit)) {
            return (MOWordLabel *)subview;
        }
    }
    return nil;
}

// delegate is invoked if user taps on word
- (void)handleTap:(UITapGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MOWordLabel *hitLabel = [self hitLabel:recognizer];
        if (hitLabel) {
            [self.delegate wordPicker:self didPickWord:hitLabel.text];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        draggedLabel = [self hitLabel:recognizer];
        dragStartCenter = draggedLabel.center;
    } else {
        if (draggedLabel) {
            [self bringSubviewToFront:draggedLabel];

            CGPoint translation = [recognizer translationInView:self];
            draggedLabel.center = CGPointMake(draggedLabel.center.x + translation.x,
                                              draggedLabel.center.y + translation.y);
            [recognizer setTranslation:CGPointMake(0, 0) inView:self];
            
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                if (!CGRectContainsPoint(self.bounds, draggedLabel.center)) {
                    [draggedLabel removeFromSuperview];
                    [_words removeObject:draggedLabel.text];
                    [self.delegate wordPicker:self didDropWord:draggedLabel.text];
                    [UIView animateWithDuration:0.3
                                     animations:^{
                                         [self updateLabelFrames];
                                     }];
                } else {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         draggedLabel.center = dragStartCenter;
                                     }
                                     completion:nil];
                }
            }
        }
    }
}


#pragma mark - View Updates

- (void)updateLabelFrames {
    
    CGPoint nextHorizontalOrigin = CGPointMake(kMargin, kMargin);
    
    for (UIView *subview in self.subviews) {

        MOWordLabel *wordLabel = (MOWordLabel *)subview;
        
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
        }
    }
}

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
        }
    }
}


@end
