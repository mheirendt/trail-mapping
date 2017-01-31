//
//  FeedPostDetailViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/4/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "FeedPostDetailViewController.h"

@interface FeedPostDetailViewController ()

@end

@implementation FeedPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.scrollView.delegate = self;
    [self.scrollView setUserInteractionEnabled:YES];
    [_scrollView.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    [self.view addSubview:_scrollView];
    self.post = [[FeedPost alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 320)];
    [self.post setDictionary:self.dict];
    [_scrollView addSubview:_post];
    _chatBox.delegate = self;
    int scrollHeight = 320;
    for (int i = 0; i < [_post.comments count]; i++) {
        float x = 0;
        float y = 320 + (i * 141);
        float width = self.view.bounds.size.width;
        float height = 139;
        Comment *container = [[Comment alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [container.layer setBackgroundColor:[UIColor whiteColor].CGColor];
        [container setUserInteractionEnabled:YES];
        User *submittedUser = [[User alloc] initWithDictionary:[_post.comments[i] objectForKey:@"submittedUser"]];
        container.comment = _post.comments[i];
        
        if (submittedUser.avatar) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:submittedUser.avatar];
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                if ( data == nil )
                return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [container.avatar setImage:[UIImage imageWithData:data]];
                });
            });
        }
        
        container.body.text = [container.comment objectForKey:@"body"];
        container.username.text = submittedUser.username;
        container.created.text = [container.comment objectForKey:@"created"];
        
        UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discernCommentAction:)];
        dismiss.cancelsTouchesInView = NO;
        [container addGestureRecognizer:dismiss];
        
        
        [_scrollView addSubview:container];
        scrollHeight += container.bounds.size.height + 3;
        
    }

    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, scrollHeight)];
    //MKCoordinateRegion region = MKCoordinateRegionForMapRect([_mapView mapRectThatFits:_path.boundingMapRect]);
    //[self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
    //self.mapView.delegate = self;
    //[self.mapView addOverlay:_path];
    
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //set notification for when keyboard shows/hides
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //set notification for when a key is pressed.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(keyPressed:)
                                                 name: UITextViewTextDidChangeNotification
                                               object: nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //friends view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFriendsView:) name:@"friendsViewDismissed" object:nil];
    
    //turn off scrolling and set the font details.
    _commentToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 200, 40)];
    [_commentToolbar setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    [_commentToolbar.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    
    _chatBox = [[UITextView alloc] initWithFrame:CGRectMake(20, 5, 200, 30)];
    _chatBox.scrollEnabled = NO;
    _chatBox.font = [UIFont fontWithName:@"Helvetica" size:14];
    _chatBox.layer.cornerRadius = 8.0f;
    _chatBox.layer.masksToBounds = YES;
    _chatBox.layer.borderWidth = 1.f;
    _chatBox.layer.borderColor = [UIColor blackColor].CGColor;
    [_chatBox setReturnKeyType:UIReturnKeySend];
    [_chatBox setEnablesReturnKeyAutomatically:YES];
    [self.commentToolbar addSubview:_chatBox];
    [self.view addSubview:_commentToolbar];
    [_chatBox becomeFirstResponder];
    
    //Send button
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setFrame:CGRectMake(self.view.bounds.size.width - 65, 5, 60, 25)];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(postComment) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton.layer setBackgroundColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:.5f].CGColor];
    _sendButton.layer.cornerRadius = 10.f;
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sendButton.clipsToBounds = YES;
    _sendButton.layer.borderWidth = 1.f;
    [_sendButton setEnabled:NO];
    [_commentToolbar addSubview:_sendButton];
    
}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) postComment {
    [_post submitComment:_chatBox.text];
    [self dismissKeyboard];
}

-(void) discernCommentAction: (UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    [self dismissKeyboard];
    //UIView *view = recognizer.view;
    //NSLog(@"%ld", (long)view.tag);
    
    UIView *tappedView = [self.view hitTest:point withEvent:nil];
    if ([tappedView isKindOfClass:[UIImageView class]]) {
        //hmmmmmm
        [tappedView setImage: [UIImage imageNamed:@"likePressed"]];
        //[self likeComment:(Comment*)tappedView];
    }
    //NSLog(@"point: %f, %f", tappedView.x, touchLocation.y);

    CGPoint touchPoint = [recognizer locationInView:tappedView];
    NSLog(@"point: %f, %f", touchPoint.x, touchPoint.y);
    if (touchPoint.y > 80) {
        if (touchPoint.x > 142 && touchPoint.x < 162) {
            //Liked
            [self likeComment:(Comment*)tappedView];
        } else if (touchPoint.x > 161 && touchPoint.x < 251) {
            //view likes
            [self viewCommentLikes:(Comment *)tappedView];
        } else if (touchPoint.x > 250) {
            //Reply
            NSLog(@"Replied");
        } else {
            //View likes
        }
    }
}

-(void) likeComment: (Comment *) view {
    NSLog(@"liked");
    [view.likeIcon setImage:[UIImage imageNamed:@"likePressed"]];
}

-(void) viewCommentLikes: (Comment *) view {
    _backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = .5f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFriendsView:)];
    [_backgroundView addGestureRecognizer:recognizer];
    [self.view addSubview:_backgroundView];
    //if (!_friendsView){
    _friendsView = [[FriendsView alloc] initWithFrame:CGRectMake(0, 0, 250, 375)];
    _friendsView.backgroundColor = [UIColor whiteColor];
    CGRect viewBounds = self.view.bounds;
    _friendsView.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds) - 70);
    _friendsView.layer.borderWidth = 1.5f;
    _friendsView.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    _friendsView.users = [NSMutableArray array];
    _friendsView.users = [view.comment objectForKey:@"likes"];
    //}
    [self.view addSubview:_friendsView];
}

-(void) dismissFriendsView:(NSNotification *)notification {
    
    [self.friendsView removeFromSuperview];
    [UIView animateWithDuration:0.5 delay:0.f options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 0;
    }
                     completion:^(BOOL finished){
                         [self.backgroundView removeFromSuperview];
                     }];
}

-(void) zoomToPath:(Path *)path {
    _path = path;
    [self.mapView addOverlay:path];
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([_mapView mapRectThatFits:path.boundingMapRect]);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
}

#pragma mark - MKOverlay methods
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[Path class]]) {
        Path *polyLine = overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)polyLine];
        aRenderer.strokeColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

#pragma mark - MKMapView Delegate methods
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([_mapView mapRectThatFits:self.path.boundingMapRect]);
    if ((mapView.region.span.latitudeDelta > region.span.latitudeDelta ) || (mapView.region.span.longitudeDelta > region.span.longitudeDelta) ) {
        //[mapView setRegion:[mapView regionThatFits:region] animated:YES];
        [mapView setVisibleMapRect:[mapView mapRectThatFits:_path.boundingMapRect] edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
    }
    if (fabs(fabs(mapView.region.center.latitude) - region.center.latitude) > (region.center.latitude / 2) ) {
        [mapView setVisibleMapRect:[mapView mapRectThatFits:_path.boundingMapRect] edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
        
    }
    if (fabs(fabs(mapView.region.center.longitude) - region.center.longitude) > (region.center.longitude / 2) ) {
        [mapView setVisibleMapRect:[mapView mapRectThatFits:_path.boundingMapRect] edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
    }
}

#pragma mark - UITextView delegate methods
-(void)dismissKeyboard {
    [_chatBox resignFirstResponder];
}

-(void) keyboardWillChangeFrame: (NSNotification*) notification {
    int height =   [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self.scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + height)];
}
-(void) keyboardWillShow: (NSNotification *) notification {
    [UIView animateWithDuration:0.01f animations:^ {
        [_commentToolbar setFrame:CGRectMake(0, self.view.bounds.size.height - 300, self.view.bounds.size.width, 50)];
    }];
}

-(void) keyboardWillHide: (NSNotification *) notification {
    [UIView animateWithDuration:0.01f animations:^ {
        self.commentToolbar.frame = CGRectMake(0, self.view.bounds.size.height + _commentToolbar.bounds.size.height, self.view.bounds.size.width, 50);
    }];
}

-(void) keyPressed: (NSNotification*) notification{
    if (_chatBox.text.length >= 1) {
        [_sendButton setEnabled:YES];
        [_sendButton.layer setBackgroundColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
    } else {
        [_sendButton setEnabled:NO];
        [_sendButton.layer setBackgroundColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:.5f].CGColor];
    }
    CGRect textRect = [_chatBox.text boundingRectWithSize:CGSizeMake(200, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:14.f]} context:nil];
    CGSize size = textRect.size;
    NSInteger newSizeH = size.height;
    //NSInteger newSizeW = size.width;
    if (_chatBox.hasText)
    {
        // if the height of our new chatbox is below 90 we can set the height
        NSString *newLine;
        if (_chatBox.text.length > 1) {
            newLine = [_chatBox.text substringFromIndex: [_chatBox.text length] - 1];
        } else {
            newLine = _chatBox.text;
        }

        if (newSizeH > _textFieldPreviousHeight && newSizeH <= 90)
        {
            [_chatBox scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
            
            // chatbox view
            CGRect chatBoxFrame = _chatBox.frame;
            NSInteger chatBoxH = chatBoxFrame.size.height;
            NSInteger chatBoxW = chatBoxFrame.size.width;
            NSLog(@"CHAT BOX SIZE : %ld X %ld", (long)chatBoxW, (long)chatBoxH);
            chatBoxFrame.size.height = newSizeH + 19;
            _chatBox.frame = chatBoxFrame;
            
            // comment toolbar view
            CGRect commentFrame = _commentToolbar.frame;
            NSInteger commentFrameH = commentFrame.size.height;
            NSInteger commentFrameW = commentFrame.size.width;
            NSLog(@"CHAT BOX SIZE : %ld X %ld", (long)commentFrameW, (long)commentFrameH);
            commentFrame.size.height = commentFrameH + 17;
            commentFrame.origin.y = commentFrame.origin.y - 16.2;
            _commentToolbar.frame = commentFrame;
            
        }
        if (newSizeH < _textFieldPreviousHeight && newSizeH <= 90) {
            // chatbox view
            CGRect chatBoxFrame = _chatBox.frame;
            NSInteger chatBoxH = chatBoxFrame.size.height;
            NSInteger chatBoxW = chatBoxFrame.size.width;
            NSLog(@"CHAT BOX SIZE : %ld X %ld", (long)chatBoxW, (long)chatBoxH);
            chatBoxFrame.size.height = newSizeH + 9;
            _chatBox.frame = chatBoxFrame;
            
            // comment toolbar view
            CGRect commentFrame = _commentToolbar.frame;
            NSInteger commentFrameH = commentFrame.size.height;
            NSInteger commentFrameW = commentFrame.size.width;
            NSLog(@"CHAT BOX SIZE : %ld X %ld", (long)commentFrameW, (long)commentFrameH);
            commentFrame.size.height = commentFrameH - 17;
            commentFrame.origin.y = commentFrame.origin.y + 16.2;
            _commentToolbar.frame = commentFrame;
        }

        if (newSizeH >= 90)
        {
            _chatBox.scrollEnabled = YES;
        }
        _textFieldPreviousHeight = newSizeH;
        
        NSString *returnKey = [_chatBox.text substringFromIndex: [_chatBox.text length] - 1];
        if([returnKey isEqualToString:@"\n"]) {
            [self postComment];
        }
    }
}

@end
