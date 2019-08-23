//	            __    __                ________
//	| |    | |  \ \  / /  | |    | |   / _______|
//	| |____| |   \ \/ /   | |____| |  / /
//	| |____| |    \  /    | |____| |  | |   _____
//	| |    | |    /  \    | |    | |  | |  |____ |
//  | |    | |   / /\ \   | |    | |  \ \______| |
//  | |    | |  /_/  \_\  | |    | |   \_________|
//
//	Copyright (c) 2012年 HXHG. All rights reserved.
//	http://www.jpush.cn
//  Created by Zhanghao
//

#import "setLocalNotificationViewController.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <CoreLocation/CoreLocation.h>

@interface setLocalNotificationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTF;
@property (weak, nonatomic) IBOutlet UITextField *bodyTF;
@property (weak, nonatomic) IBOutlet UITextField *badgeTF;
@property (weak, nonatomic) IBOutlet UITextField *actionTF;
@property (weak, nonatomic) IBOutlet UITextField *soundTF;
@property (weak, nonatomic) IBOutlet UITextField *cateforyIdentifierTF;
@property (weak, nonatomic) IBOutlet UITextField *threadIDTF;
@property (weak, nonatomic) IBOutlet UITextField *summaryArgumentTF;
@property (weak, nonatomic) IBOutlet UITextField *summaryArgCountTF;
@property (weak, nonatomic) IBOutlet UITextField *requestIdentifierTF;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSW;

@property (weak, nonatomic) IBOutlet UISwitch *deliveredSW;


@end

@implementation setLocalNotificationViewController {
    CGRect _frame;
    id _notification;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self currentFrame];
}

#pragma mark - add notification
//添加一个指定日期触发的通知
- (IBAction)addNotificationWithDateTrigger:(id)sender {
  
  JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    //周二早上8点
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = 2;
    components.hour = 8;
    trigger.dateComponents = components;
  }
  else {
    //date
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:20];
    trigger.fireDate = fireDate;
  }
  trigger.repeat = self.repeatSW.isOn;
  JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
  request.content = [self generateNotificationCotent];
  request.trigger = trigger;
  request.completionHandler = ^(id result) {
    // iOS10以上成功则result为UNNotificationRequest对象，失败则result为nil
    // iOS10以下成功result为UILocalNotification对象，失败则result为nil
    if (result) {
      NSLog(@"添加日期通知成功 --- %@", result);
      _notification = result;
//      [self clearAllInput];
      NSString *message = @"";
      if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        message = [NSString stringWithFormat:@"iOS10以上，%@触发", trigger.dateComponents];
      }else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [dateFormatter stringFromDate:trigger.fireDate];
        message = [NSString stringWithFormat:@"iOS10以下，%@触发", dateStr];
      }
      [self showAlertControllerWithTitle:@"添加 date 通知成功" message:message];
    }else {
      [self showAlertControllerWithTitle:@"添加 date 通知失败" message:nil];
    }
  };
  request.requestIdentifier = self.requestIdentifierTF.text;
  [JPUSHService addNotification:request];
}

//添加一个地理位置触发的通知
- (IBAction)addNotificationWithRegionTrigger:(id)sender {
  JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
    CLLocationCoordinate2D cen = CLLocationCoordinate2DMake(22.5531706, 113.9025006);
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:cen
                                                                 radius:2000.0
                                                             identifier:@"JIGUANG"];
    trigger.region = region;
    trigger.repeat = self.repeatSW.isOn;
  }else {
    NSLog(@"region 触发通知只在 iOS8 以上有效哦……");
    [self showAlertControllerWithTitle:nil message:@"region 触发通知只在 iOS8 以上有效"];
    return;
  }
  JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
  request.content = [self generateNotificationCotent];
  request.trigger = trigger;
  request.completionHandler = ^(id result) {
    if (result) {
      NSLog(@"添加地理位置通知成功 --- %@", result);
      _notification = result;
//      [self clearAllInput];
      NSString *message = [NSString stringWithFormat:@"%@",trigger.region];
      [self showAlertControllerWithTitle:@"添加 region 通知成功" message:message];
    }else {
      [self showAlertControllerWithTitle:@"添加 region 通知失败" message:nil];
    }
  };
  request.requestIdentifier = self.requestIdentifierTF.text;
  [JPUSHService addNotification:request];
}

//添加一个时间戳触发的通知
- (IBAction)addNotificationWithTimeintervalTrigger:(id)sender {
  JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    //20s之后触发
    trigger.timeInterval = 20;
    if (trigger.timeInterval < 60) {
      //系统原因，设置重复触发时间必须在60s以上,否则会crash
      trigger.repeat = NO;
    }else {
      trigger.repeat = self.repeatSW.isOn;
    }
  }else {
    NSLog(@"timeInterval 触发通知只在 iOS10 以上有效哦……");
    [self showAlertControllerWithTitle:nil message:@"timeInterval 触发通知只在 iOS10 以上有效"];
    return;
  }
  JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
  request.content = [self generateNotificationCotent];
  request.trigger = trigger;
  request.completionHandler = ^(id result) {
    if (result) {
      NSLog(@"添加 timeInterval 通知成功 --- %@", result);
      _notification = result;
//      [self clearAllInput];
      NSString *message = [NSString stringWithFormat:@"iOS10以上，%.0f秒后触发",trigger.timeInterval];
      [self showAlertControllerWithTitle:@"添加 timeInterval 通知成功" message:message];
    }else {
      [self showAlertControllerWithTitle:@"添加 timeInterval 通知失败" message:nil];
    }
  };
  request.requestIdentifier = self.requestIdentifierTF.text;
  [JPUSHService addNotification:request];
}

#pragma mark - find notification

//查找指定ID的通知
- (IBAction)findNotifationWithIdentifier:(id)sender {
  
  JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
  //note:identifiers这里可以设置多个identifier来查找多个指定推送。
  identifier.identifiers = @[self.requestIdentifierTF.text];
  //delivered iOS10以上有效，YES表示在通知中心显示的里面查找，NO则是在待推送的里面查找；iOS10以下无效
  identifier.delivered = self.deliveredSW.isOn;
  identifier.findCompletionHandler = ^(NSArray *results) {
    //results iOS10以下返回UILocalNotification对象数组
    //iOS10以上 根据delivered传入值返回UNNotification或UNNotificationRequest对象数组
    NSLog(@"查找指定通知 - 返回结果为：%@", results);
    NSString *title = [NSString stringWithFormat:@"查找指定通知 %ld 条",results.count];
    NSString *message = [NSString stringWithFormat:@"%@",results];
    [self showAlertControllerWithTitle:title message:message];
  };
  [JPUSHService findNotification:identifier];
}

//查找所有通知
- (IBAction)findAllNotification:(id)sender {
  
  JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
  //iOS10以上 identifiers 为nil或者空数组，会根据delivered值查找对应推送。delivered为 YES 表示查找通知中心显示的所有通知，NO则是查找所有待推送通知
  //iOS10以下 identifiers 为nil或者空数组，会找到所有未被触发的通知。
  identifier.identifiers = nil;
  identifier.delivered = self.deliveredSW.isOn;
  identifier.findCompletionHandler = ^(NSArray *results) {
    NSLog(@"查找所有通知 - 返回结果为：%@", results);
    NSString *title = [NSString stringWithFormat:@"查找所有通知 %ld 条",results.count];
    NSString *message = [NSString stringWithFormat:@"%@",results];
    [self showAlertControllerWithTitle:title message:message];
  };
  [JPUSHService findNotification:identifier];
}

#pragma mark - remove notification
//删除指定ID的通知
- (IBAction)removeNotificationWithIdentifier:(id)sender {
  
  JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
  //note:identifiers这里可以设置多个identifier来删除多个指定推送。
  identifier.identifiers = @[self.requestIdentifierTF.text];
  //在iOS10以下，可以通过通知对象来删除具体的某一个通知
//  identifier.notificationObj = _notification;
  identifier.delivered = self.deliveredSW.isOn;
  [JPUSHService removeNotification:identifier];
  NSLog(@"删除指定通知");
  [self showAlertControllerWithTitle:nil message:@"删除指定通知"];
}

//删除所有通知
- (IBAction)removeAllNotification:(id)sender {
  //iOS10以下 移除所有推送；
  //iOS10以上 移除所有在通知中心显示推送和待推送请求, 当然也可以通过 delivered 属性来选择移除所有通知中心的通知，或者是未触发的所有通知
  [JPUSHService removeNotification:nil];
  NSLog(@"删除所有通知");
  [self showAlertControllerWithTitle:nil message:@"删除所有通知"];
  //  JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
  //  identifier.identifiers = nil;
  //  identifier.delivered = self.deliveredSW.isOn;  //移除所有在通知中心显示的，等于NO则为移除所有待推送的
  //  [JPUSHService removeNotification:identifier];
}

- (JPushNotificationContent *)generateNotificationCotent {
  JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
  content.title = self.titleTF.text;
  content.subtitle = self.subtitleTF.text;
  content.body = self.bodyTF.text;
  content.badge = @([self.badgeTF.text integerValue]);
  content.action = self.actionTF.text;
  content.categoryIdentifier = self.cateforyIdentifierTF.text;
  content.threadIdentifier = self.threadIDTF.text;
//  content.userInfo = @{@"extra":@"xxxx"};
//  UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"pushTest" URL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ios7" ofType:@"png"]] options:nil error:nil];
//  content.attachments = @[attachment];
//  content.launchImageName = @"";
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    JPushNotificationSound *soundSetting = [[JPushNotificationSound alloc] init];
    soundSetting.soundName = self.soundTF.text;
    //如果是告警通知
    if (@available(iOS 12.0, *)) {
      soundSetting.criticalSoundName = @"sound.caf";
      soundSetting.criticalSoundVolume = 0.9;
    }
    content.soundSetting = soundSetting;
  }else {
    content.sound = self.soundTF.text;
  }
  if (@available(iOS 12.0, *)) {
    content.summaryArgument = self.summaryArgumentTF.text;
    content.summaryArgumentCount = [self.summaryArgCountTF.text integerValue];
  }
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    if (self.requestIdentifierTF.text.length == 0) {
      [self showAlertControllerWithTitle:nil message:@"通知identifier不能为空"];
    }
  }
  return content;
}


- (void)clearAllInput {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.titleTF.text = @"";
    self.subtitleTF.text = @"";
    self.bodyTF.text = @"";
    self.badgeTF.text = @"";
    self.actionTF.text = @"";
    self.soundTF.text = @"";
    self.cateforyIdentifierTF.text = @"";
    self.threadIDTF.text = @"";
    self.summaryArgumentTF.text = @"";
    self.summaryArgCountTF.text = @"";
    self.requestIdentifierTF.text = @"";
  });
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (textField == self.requestIdentifierTF) {
    _backgroundView.frame = CGRectMake(_frame.origin.x, _frame.origin.y - 30,
                                       _frame.size.width, _frame.size.height);
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  _backgroundView.frame = _frame;
  return YES;
}


- (IBAction)View_TouchDown:(id)sender {
  // 发送resignFirstResponder.
  [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                             to:nil
                                           from:nil
                                       forEvent:nil];
  _backgroundView.frame = _frame;
}

- (void)currentFrame {
  int fixLength;
#ifdef __IPHONE_7_0
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
    fixLength = 0;
  } else {
    fixLength = 20;
  }
#else
  fixLength = 20;
#endif
  _frame =
  CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - fixLength,
             self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
//  [self clearAllInput];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
      }];
      [alert addAction: closeAction];
      [self presentViewController:alert animated:YES completion:nil];
    }else {
      UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:title
                                 message:message
                                delegate:self
                       cancelButtonTitle:@"确定"
                       otherButtonTitles:nil, nil];
      [alert show];
    }
  });
}


@end
