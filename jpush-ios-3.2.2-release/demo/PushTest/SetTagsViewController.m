//
//  SetTagsViewController.m
//  PushSDK
//
//  Created by ys on 16/05/2017.
//  Copyright © 2017 hxhg. All rights reserved.
//

#import "SetTagsViewController.h"
#import "JPUSHService.h"
@interface SetTagsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextField;
@property (weak, nonatomic) IBOutlet UITextView *holderTextView;

@end

@implementation SetTagsViewController

static NSInteger seq = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.holderTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

//增加tag集合
- (IBAction)addTags:(id)sender {
    [JPUSHService addTags:[self tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
////覆盖tag集合 调用该接口会覆盖用户所有的tags
- (IBAction)setTags:(id)sender {
    [JPUSHService setTags:[self tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
//获取所有tag
- (IBAction)getAllTags:(id)sender {
    [JPUSHService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}
//删除指定tag
- (IBAction)deleteTags:(id)sender {
    [JPUSHService deleteTags:[self tags] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}

//删除所有tag
- (IBAction)cleanTags:(id)sender {
    [JPUSHService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
      [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@", iTags.allObjects] andSeq:seq];
    } seq:[self seq]];
}

//验证tag是否已经绑定
- (IBAction)vaildTag:(id)sender {
  [JPUSHService validTag:[[self tags] anyObject] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind) {
    [self inputResponseCode:iResCode content:[NSString stringWithFormat:@"%@ isBind:%d", iTags.allObjects, isBind] andSeq:seq];
  } seq:[self seq]];
}

//设置alias
- (IBAction)setAlias:(id)sender {
    [JPUSHService setAlias:[self alias] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
      [self inputResponseCode:iResCode content:iAlias andSeq:seq];
    } seq:[self seq]];
}

//删除alias
- (IBAction)deleteAlias:(id)sender {
  [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
    [self inputResponseCode:iResCode content:iAlias andSeq:seq];
  } seq:[self seq]];
}

//查询当前设置的alias
- (IBAction)getAlias:(id)sender {
  [JPUSHService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
    [self inputResponseCode:iResCode content:iAlias andSeq:seq];
  } seq:[self seq]];
}
- (IBAction)resetTextField:(id)sender {
  self.tagsTextField.text = nil;
  self.aliasTextField.text = nil;
}
- (IBAction)resetTextView:(id)sender {
  self.holderTextView.text = nil;
}

- (NSInteger)seq {
  return ++ seq;
}

- (NSSet<NSString *> *)tags {
  NSArray * tagsList = [self.tagsTextField.text componentsSeparatedByString:@","];
  if (self.tagsTextField.text.length > 0 && !tagsList.count) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有输入tags,请使用逗号作为tags分隔符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
  }
  NSMutableSet * tags = [[NSMutableSet alloc] init];
  [tags addObjectsFromArray:tagsList];
  //过滤掉无效的tag
  NSSet *newTags = [JPUSHService filterValidTags:tags];
  return newTags;
}

- (NSString *)alias {
  return self.aliasTextField.text;
}

- (void)inputResponseCode:(NSInteger)code content:(NSString *)content andSeq:(NSInteger)seq{
  self.holderTextView.text = [self.holderTextView.text stringByAppendingFormat:@"\n\n code:%ld content:%@ seq:%ld", code, content, seq];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.tagsTextField resignFirstResponder];
  [self.aliasTextField resignFirstResponder];
}

@end
