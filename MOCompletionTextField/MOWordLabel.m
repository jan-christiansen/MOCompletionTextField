//
//  MOWordLabel.m
//  MOCompletionTextField
//
//  Created by Jan Christiansen on 9/25/12.
//  Copyright (c) 2012, Monoid - Development and Consulting - Jan Christiansen
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
#import "MOWordLabel.h"


// distance between two horizontally subsequent words
static const float kWidthInnerMargin = 4;

// distance between two rows of words
static const float kHeightInnerMargin = 2;


@implementation MOWordLabel


- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self initializeMOWordLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeMOWordLabel];
    }
    return self;
}

- (void)initializeMOWordLabel {

    self.textColor = [UIColor colorWithRed:0 green:100/255.0 blue:200/255.0 alpha:1];
    self.textAlignment = UITextAlignmentCenter;

    self.layer.masksToBounds = NO;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:180/255.0 green:200/255.0 blue:1 alpha:1].CGColor;

    // add shadow to label
    self.layer.shadowOffset = CGSizeMake(2, 2);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
}

- (void)sizeToFit {

    // calculate frame for word label
    CGSize constraintSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    CGSize labelSize = [self.text sizeWithFont:self.font
                             constrainedToSize:constraintSize
                                 lineBreakMode:UILineBreakModeMiddleTruncation];
    CGRect newFrame = self.frame;
    newFrame.size.width = labelSize.width + 2*kWidthInnerMargin;
    newFrame.size.height = labelSize.height + 2*kHeightInnerMargin;
    self.frame = newFrame;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
}


@end
