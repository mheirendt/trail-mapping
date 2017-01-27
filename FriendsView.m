//
//  FriendsView.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/15/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "FriendsView.h"

@implementation FriendsView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    //self.users = [NSMutableArray array];
    _userTable = [[UITableView alloc] initWithFrame:rect];
    _userTable.delegate = self;
    _userTable.dataSource = self;
    [self addSubview:_userTable];
    
    //Okay Button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setFrame:CGRectMake(0, 0, 70, 70)];
    [self.closeButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:[UIImage imageNamed:@"Complete"] forState:UIControlStateNormal];
    [self addSubview:self.closeButton];
    CGRect bounds = self.closeButton.superview.bounds;
    self.closeButton.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + 150);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {
        
        [tableView registerNib:[UINib nibWithNibName:@"FriendsViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    }
    User *cellUser = [[User alloc] initWithDictionary:[_users objectAtIndex:indexPath.row]];
    cell.usernameLabel.text = cellUser.username;//[_users objectAtIndex:indexPath.row];//cellUser.username;
    if (cellUser.avatar) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:cellUser.avatar];
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
            if ( data == nil )
            return;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatar.image = [UIImage imageWithData:data];
            });
        });
    }
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *cellUser = [[User alloc] initWithDictionary:[_users objectAtIndex:indexPath.row]];
    [self dismissView:cellUser];
}

-(void)dismissView:(User *) user{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"friendsViewDismissed" object:user]];
}


@end
