//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesCollectionViewCellOutgoing.h"

@implementation JSQMessagesCollectionViewCellOutgoing

#pragma mark - Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentRight;
    self.textView.textColor = [UIColor blackColor];
    self.cellBottomLabel.textAlignment = NSTextAlignmentRight;
    self.cellTopLabel.textColor = [UIColor grayColor];
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.backgroundView11.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                              cornerRadii:CGSizeMake(10, 10)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    CGRect rt = self.messageBubbleImageView.bounds;
    maskLayer.frame = rt;
    maskLayer.path = maskPath.CGPath;
    
    self.backgroundView11.layer.mask = maskLayer;
}

@end
