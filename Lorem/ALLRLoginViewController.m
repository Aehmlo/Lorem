//
//  ALLRLoginViewController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 2/1/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRLoginViewController.h"

@interface ALLRLoginViewController ()

@end

@implementation ALLRLoginViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?2:1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (void)saveCredentials{
    [self.clientIDEntryField resignFirstResponder];
    [self.APIKeyEntryField resignFirstResponder];
    if (!inputIsValid(self.clientIDEntryField.text)) {
        [self.clientIDEntryField becomeFirstResponder];
        return;
    }
    if (!inputIsValid(self.APIKeyEntryField.text)) {
        [self.APIKeyEntryField becomeFirstResponder];
        return;
    }else{
        [[ALLRCredentialManager sharedManager] _setCredentials:@{@"ClientID": self.clientIDEntryField.text, @"APIKey": self.APIKeyEntryField.text} completion:^(BOOL successful){
            if(successful){
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if([textField isEqual:self.clientIDEntryField]) [self.APIKeyEntryField becomeFirstResponder];
    else if([textField isEqual:self.APIKeyEntryField]) [self saveCredentials];
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.aehmlo.lorem.loginCell"];
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.aehmlo.lorem.loginCell"];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.section==0){
        switch(indexPath.row){
            case 0:
                self.clientIDEntryField = [[UITextField alloc] initWithFrame:(CGRect){{10, 0}, {self.view.bounds.size.width-20, 40}}];
                self.clientIDEntryField.delegate = self;
                self.clientIDEntryField.placeholder = @"Client ID";
                self.clientIDEntryField.returnKeyType = UIReturnKeyNext;
                [cell addSubview:self.clientIDEntryField];
                break;
            case 1:
                self.APIKeyEntryField = [[UITextField alloc] initWithFrame:(CGRect){{10, 0}, {self.view.bounds.size.width-20, 40}}];
                self.APIKeyEntryField.delegate = self;
                self.APIKeyEntryField.placeholder = @"API Key";
                self.APIKeyEntryField.returnKeyType = UIReturnKeyGo;
                [cell addSubview:self.APIKeyEntryField];
                break;
        }
    }else{
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [saveButton setTitle:@"save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveCredentials) forControlEvents:UIControlEventTouchUpInside];
        saveButton.frame = (CGRect){CGPointZero ,{self.view.bounds.size.width, 40}};
        saveButton.tintColor = [UIColor DOBlueColor];
        [cell addSubview:saveButton];
    }
    return cell;
}

static BOOL inputIsValid(NSString *input){
    if(!input || [input isEqualToString:@""]) return NO;
    NSCharacterSet *set = [NSCharacterSet alphanumericCharacterSet];
    return ([input rangeOfCharacterFromSet:[set invertedSet]].location==NSNotFound);
}

- (instancetype)init{
    if ((self = [super init])){
        self.title = @"Authenticate";
    }
    return self;
}



- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.tableViewController.tableView.frame = self.view.bounds;
    self.tableViewController.tableView.scrollEnabled = NO;
    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.delegate = self;
    [self.view addSubview:self.tableViewController.tableView];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationItem.hidesBackButton = NO;
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/reloadDroplets" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
