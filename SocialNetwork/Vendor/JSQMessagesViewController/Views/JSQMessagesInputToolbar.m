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

#import "JSQMessagesInputToolbar.h"

#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UIView+JSQMessages.h"

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;


@interface JSQMessagesInputToolbar ()

@property (assign, nonatomic) BOOL jsq_isObserving;

- (void)jsq_leftBarButtonPressed:(UIButton *)sender;
- (void)jsq_rightBarButtonPressed:(UIButton *)sender;

- (void)jsq_addObservers;
- (void)jsq_removeObservers;
@property UIImage* sendImage, *recordImage;
@end



@implementation JSQMessagesInputToolbar

@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.jsq_isObserving = NO;
    self.sendButtonOnRight = YES;

    self.preferredDefaultHeight = 52.0f;

    JSQMessagesToolbarContentView *toolbarContentView =  [self loadToolbarContentView];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;

    [self jsq_addObservers];
    
    self.contentView.leftBarButtonItem = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    self.contentView.leftBarButtonItem1 = [JSQMessagesToolbarButtonFactory rightmiddleImage];
    self.contentView.leftBarButtonItem2 = [JSQMessagesToolbarButtonFactory rightermiddleImage];
    self.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory rightImage];
    self.sendImage = [UIImage imageNamed:@"Untitled 2.png"];
    self.recordImage = [UIImage imageNamed:@"record11.png"];
    [self toggleSendButtonEnabled];
}

- (JSQMessagesToolbarContentView *)loadToolbarContentView
{
    NSArray *nibViews = [[NSBundle bundleForClass:[JSQMessagesInputToolbar class]] loadNibNamed:NSStringFromClass([JSQMessagesToolbarContentView class])
                                                                                          owner:nil
                                                                                        options:nil];
    return nibViews.firstObject;
}

- (void)dealloc
{
    [self jsq_removeObservers];
    _contentView = nil;
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight
{
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

#pragma mark - Actions

- (void)jsq_leftBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)jsq_leftBarButtonPressed1:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressLeftBarButton1:sender];
}

- (void)jsq_leftBarButtonPressed2:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressLeftBarButton2:sender];
}


- (void)jsq_rightBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled
{
    BOOL hasText = [self.contentView.textView hasText];

    if (self.sendButtonOnRight) {
//        UIImage* image = hasText ? self.sendImage : self.recordImage;
        UIImage* image = self.sendImage;
        [self.contentView.rightBarButtonItem setImage:image forState:UIControlStateNormal];
        [self.contentView.rightBarButtonItem setImage:image forState:UIControlStateHighlighted];
        
        self.contentView.rightBarButtonItem.enabled = YES;
    }
    else {
        self.contentView.leftBarButtonItem.enabled = YES;
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {

            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {

                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem1))]) {
                
                [self.contentView.leftBarButtonItem1 removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem1 addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed1:)
                                             forControlEvents:UIControlEventTouchUpInside];
            } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem2))]) {
                
                [self.contentView.leftBarButtonItem2 removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem2 addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed2:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {

                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(jsq_rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }

            [self toggleSendButtonEnabled];
        }
    }
}

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem1))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem2))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }

    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];

        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    _jsq_isObserving = NO;
}

@end
