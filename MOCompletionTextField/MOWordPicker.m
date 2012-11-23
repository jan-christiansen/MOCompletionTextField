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

    MOWordLabel *_draggedLabel;
    CGPoint _dragStartCenter;
}


@property(strong, nonatomic) NSMutableArray *shownWords;

@property(strong, nonatomic) NSMutableArray *hiddenWords;

@property(assign, nonatomic) CGPoint nextHorizontalOrigin;

@property(assign, nonatomic) CGPoint nextVerticalOrigin;


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
        _draggedLabel = [self hitLabel:recognizer];
        _dragStartCenter = _draggedLabel.center;
    } else {
        if (_draggedLabel) {
            [self bringSubviewToFront:_draggedLabel];

            CGPoint translation = [recognizer translationInView:self];
            _draggedLabel.center = CGPointMake(_draggedLabel.center.x + translation.x,
                                               _draggedLabel.center.y + translation.y);
            [recognizer setTranslation:CGPointMake(0, 0) inView:self];
            
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                if (!CGRectContainsPoint(self.bounds, _draggedLabel.center)) {
                    [_draggedLabel removeFromSuperview];
                    [self.shownWords removeObject:_draggedLabel.text];
                    [self.delegate wordPicker:self didDropWord:_draggedLabel.text];
                    [UIView animateWithDuration:0.3
                                     animations:^{
                                         [self updateLabelFrames];
                                     } completion:^(BOOL __unused finished) {
                                         [self addNewLabelFrames];
                                     }];
                } else {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         _draggedLabel.center = _dragStartCenter;
                                     }
                                     completion:nil];
                }
            }
        }
    }
}


#pragma mark - View Updates

- (void)updateLabelFrames {

    self.nextHorizontalOrigin = CGPointMake(kMargin, kMargin);

    for (UIView *subview in self.subviews) {

        MOWordLabel *wordLabel = (MOWordLabel *)subview;
        CGSize labelSize = [wordLabel calculateSize];

        if (self.nextHorizontalOrigin.x + labelSize.width + 10 > self.bounds.size.width) {
            self.nextVerticalOrigin = CGPointMake(kMargin, self.nextHorizontalOrigin.y + labelSize.height + kMargin);
        } else {
            self.nextVerticalOrigin = self.nextHorizontalOrigin;
        }

        if (self.nextVerticalOrigin.y + labelSize.height < self.bounds.size.height) {

            CGRect labelFrame;
            labelFrame.size = labelSize;

            labelFrame.origin.x = self.nextVerticalOrigin.x;
            labelFrame.origin.y = self.nextVerticalOrigin.y;

            self.nextHorizontalOrigin = CGPointMake(labelFrame.origin.x + labelFrame.size.width + kMargin,
                                                    labelFrame.origin.y);
            
            // add label
            wordLabel.frame = labelFrame;
        }
    }
}

- (void)addNewLabelFrames {

    // add new labels
    NSArray *temp = self.hiddenWords.copy;
    for (NSString *word in temp) {

        // add label
        MOWordLabel *wordLabel = [[MOWordLabel alloc] initWithFrame:CGRectZero];
        wordLabel.alpha = 0;
        wordLabel.text = word;
        wordLabel.font = [UIFont systemFontOfSize:kFontSize];
        [wordLabel sizeToFit];

        CGSize labelSize = [wordLabel calculateSize];

        if (self.nextHorizontalOrigin.x + labelSize.width + 10 > self.bounds.size.width) {
            self.nextVerticalOrigin = CGPointMake(kMargin, self.nextHorizontalOrigin.y + labelSize.height + kMargin);
        } else {
            self.nextVerticalOrigin = self.nextHorizontalOrigin;
        }

        if (self.nextVerticalOrigin.y + labelSize.height < self.bounds.size.height) {

            CGRect labelFrame;
            labelFrame.size = labelSize;

            labelFrame.origin.x = self.nextVerticalOrigin.x;
            labelFrame.origin.y = self.nextVerticalOrigin.y;

            self.nextHorizontalOrigin = CGPointMake(labelFrame.origin.x + labelFrame.size.width + kMargin,
                                                    labelFrame.origin.y);
            
            // add label
            wordLabel.frame = labelFrame;
            [self addSubview:wordLabel];

            [UIView animateWithDuration:0.2
                             animations:^{
                                 wordLabel.alpha = 1;
                             }];

            [self.hiddenWords removeObject:word];
            [self.shownWords addObject:word];
        }
    }
}

- (void)updateView {

    self.shownWords = @[].mutableCopy;
    self.hiddenWords = @[].mutableCopy;

    self.nextHorizontalOrigin = CGPointMake(kMargin, kMargin);

    NSMutableArray *oldLabels = self.subviews.mutableCopy;

    // add labels
    for (NSString *word in self.words) {

        MOWordLabel *wordLabel;
        if (oldLabels.count > 0) {
            wordLabel = [oldLabels objectAtIndex:0];
            [oldLabels removeObjectAtIndex:0];
        } else {
            // we cannot reuse a existing subview, build a new one
            wordLabel = [[MOWordLabel alloc] initWithFrame:CGRectZero];
            wordLabel.font = [UIFont systemFontOfSize:kFontSize];
            [self addSubview:wordLabel];
        }

        wordLabel.text = word;
        CGSize labelSize = [wordLabel calculateSize];

        if (self.nextHorizontalOrigin.x + labelSize.width + 10 > self.bounds.size.width) {
            self.nextVerticalOrigin = CGPointMake(kMargin, self.nextHorizontalOrigin.y + labelSize.height + kMargin);
        } else {
            self.nextVerticalOrigin = self.nextHorizontalOrigin;
        }
    
        CGRect labelFrame;
        labelFrame.size = labelSize;

        if (self.nextVerticalOrigin.y + labelFrame.size.height < self.bounds.size.height) {

            labelFrame.origin.x = self.nextVerticalOrigin.x;
            labelFrame.origin.y = self.nextVerticalOrigin.y;

            self.nextHorizontalOrigin = CGPointMake(labelFrame.origin.x + labelFrame.size.width + kMargin,
                                                    labelFrame.origin.y);

            wordLabel.frame = labelFrame;

            [self.shownWords addObject:word];
        } else {
            [wordLabel removeFromSuperview];
            [self.hiddenWords addObject:word];
        }
    }

    // remove subviews that are not reused
    for (UIView *oldLabel in oldLabels) {
        [oldLabel removeFromSuperview];
    }
}


@end
