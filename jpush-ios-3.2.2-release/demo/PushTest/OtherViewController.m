//
//  OtherViewController.m
//  PushTest
//
//  Created by ayy on 2018/7/17.
//

#import "OtherViewController.h"
#import "JPUSHService.h"
#import <CoreLocation/CoreLocation.h>

@interface OtherViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *badgeCountTF;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumTF;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTF;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTF;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@property(nonatomic, strong) CLLocationManager *currentManager;
@property (nonatomic, assign)BOOL locationUpdated;

@end

@implementation OtherViewController {
  CGRect _frame;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self currentFrame];
  
  if ([CLLocationManager locationServicesEnabled]) {
//    NSLog(@"您的设备的［设置］－［隐私］－［定位］已开启");
    _currentManager = [[CLLocationManager alloc] init];
    _currentManager.delegate = self;
    [_currentManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //请求定位权限
    if([_currentManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
      [_currentManager requestWhenInUseAuthorization];
    }else {
      [_currentManager startUpdatingLocation];
    }
  }
}

- (IBAction)clearAllInput:(id)sender {
  self.badgeCountTF.text = @"";
  self.mobileNumTF.text = @"";
  self.latitudeTF.text = @"";
  self.longitudeTF.text = @"";
}

//设置角标到JPUSH服务器
- (IBAction)reportBadge:(id)sender {
  [self resetFrame];
  NSString *stringBadge = self.badgeCountTF.text;
  if (stringBadge.length > 0) {
    int value = [stringBadge intValue];
    NSLog(@"send badge:%d to jpush server", value);
    [self showAlertControllerWithTitle:nil message:[NSString stringWithFormat:@"send badge:%d to jpush server", value]];
    [JPUSHService setBadge:value];
  }else {
    NSLog(@"please input badge count");
    [self showAlertControllerWithTitle:nil message:@"please input badge count"];
  }
}

//设置手机号码
- (IBAction)reportMobileNumber:(id)sender {
  [self resetFrame];
  NSString *mobileStr = self.mobileNumTF.text;
  if (mobileStr.length > 0) {
    [JPUSHService setMobileNumber:mobileStr completion:^(NSError *error) {
      if (!error) {
        NSLog(@"report mobile number success!");
        [self showAlertControllerWithTitle:nil message:@"report mobile number success!"];
      }else {
        NSLog(@"report mobile number error: %@", error);
        [self showAlertControllerWithTitle:nil message:[NSString stringWithFormat:@"report mobile number error: %@", error]];
      }
    }];
  }else {
    NSLog(@"please input valid mobile number");
    [self showAlertControllerWithTitle:nil message:@"please input valid mobile number"];
  }
}

//上报用户location信息，用户手动设置经纬度
- (IBAction)setLatitudeAndLongitude:(id)sender {
  [self resetFrame];
  NSString *latStr = self.latitudeTF.text;
  NSString *lngStr = self.longitudeTF.text;
  if (!latStr.length && !lngStr.length) {
    NSLog(@"please input valid latitude or longitude");
    [self showAlertControllerWithTitle:nil message:@"please input valid latitude or longitude"];
    return;
  }
  double lat = [latStr doubleValue];
  double lng = [lngStr doubleValue];
  [JPUSHService setLatitude:lat longitude:lng];
  
  [self showAlertControllerWithTitle:nil message:[NSString stringWithFormat:@"set latitude:%f and longitude:%f", lat, lng]];
}

/* demo 展示自动获取当前位置，并上报
 * iOS11上要弹出获取地理位置的弹框，建议在 info.plist 配置以下3个key。
 * NSLocationAlwaysAndWhenInUseUsageDescription
 * NSLocationAlwaysUsageDescription
 * NSLocationWhenInUseUsageDescription
 */
- (IBAction)setLocation:(id)sender {
  [self resetFrame];
  [_currentManager startUpdatingLocation];
  _locationUpdated = NO;
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  if (_locationUpdated) {
    return;
  }
  if ([locations isKindOfClass:[NSArray class]] && locations.count > 0) {
    CLLocation *location = [locations lastObject];
    if (!location || location.horizontalAccuracy < 0 || location.verticalAccuracy < 0) {
      return;
    }
    //上报location
    [JPUSHService setLocation:location];
    _locationUpdated = YES;
    [self showAlertControllerWithTitle:nil message:[NSString stringWithFormat:@"set location: %@",location]];
    [manager stopUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"get location error: %@", error);
  [manager stopUpdatingLocation];
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (textField == self.latitudeTF || textField == self.longitudeTF) {
    self.backgroundView.frame = CGRectMake(_frame.origin.x, _frame.origin.y - 80,
                                           _frame.size.width, _frame.size.height);
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  self.backgroundView.frame = _frame;
  return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self resetFrame];
}

- (void) resetFrame {
  [self.view endEditing:YES];
  self.backgroundView.frame = _frame;
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




@end
