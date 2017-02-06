//
//  ViewController.m
//  XQQApplePay
//
//  Created by XQQ on 16/9/13.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>
@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *payView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //判断是否支持苹果支付
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        NSLog(@"不支持applepay");
        self.payView.hidden = YES;
    }else if(![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay]]){//判断是否添加了银行卡 没有添加visa和银联卡
        //PKPaymentNetworkChinaUnionPay
        //创建一个按钮 跳转到添加银行卡
        PKPaymentButton * button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleWhiteOutline];
        [button addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:button];
    }else{//直接开始购买
        //创建一个按钮 跳转到开始购买
        PKPaymentButton * button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
        [button addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:button];
    }
}

- (void)jump{
    PKPassLibrary * pl = [[PKPassLibrary alloc]init];
    [pl openPaymentSetup];
}
- (void)buy{
    //购买商品 开始支付
    //创建一个支付请求
    PKPaymentRequest * request = [[PKPaymentRequest alloc]init];
    //配置商家ID
    request.merchantIdentifier = @"merchant.ApplePayUIP";
    //货币代码 国家代码
    request.countryCode = @"CN";
    request.currencyCode = @"CNY";
    //支付网络
    request.supportedNetworks = @[PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay];
    //客户处理方式
    request.merchantCapabilities = PKMerchantCapability3DS;
    //配置购买的商品列表
    NSDecimalNumber * price =[NSDecimalNumber decimalNumberWithString:@"10.0"];
    PKPaymentSummaryItem * item = [PKPaymentSummaryItem summaryItemWithLabel:@"电脑" amount:price];
    
    NSDecimalNumber * price22 =[NSDecimalNumber decimalNumberWithString:@"88.0"];
    PKPaymentSummaryItem * item22 = [PKPaymentSummaryItem summaryItemWithLabel:@"水果" amount:price22];
    
    
    NSDecimalNumber * price33 =[NSDecimalNumber decimalNumberWithString:@"100.0"];
    PKPaymentSummaryItem * item33 = [PKPaymentSummaryItem summaryItemWithLabel:@"nike" amount:price33];
    
    
    NSDecimalNumber * price44 =[NSDecimalNumber decimalNumberWithString:@"198.0"];
    PKPaymentSummaryItem * item44 = [PKPaymentSummaryItem summaryItemWithLabel:@"小哥很寂寞" amount:price44];
    //最后一个为汇总
    request.paymentSummaryItems = @[item,item22,item33,item44];
    
    //配置请求的附加项
    //是否显示发票收货地址.显示哪些选项
    request.requiredBillingAddressFields = PKAddressFieldAll;
    
    //是否显示快递地址
    request.requiredShippingAddressFields = PKAddressFieldAll;
    //配置快递方式
    NSDecimalNumber * price1=[NSDecimalNumber decimalNumberWithString:@"10.0"];
    PKShippingMethod * methods = [PKShippingMethod summaryItemWithLabel:@"顺丰快递" amount:price1];
    methods.identifier = @"shunfeng";
    methods.detail = @"24小时送货";
    
    NSDecimalNumber * price2=[NSDecimalNumber decimalNumberWithString:@"0.1"];
    PKShippingMethod * methods1 = [PKShippingMethod summaryItemWithLabel:@"圆通快递" amount:price2];
    methods1.identifier = @"yuantong";
    methods1.detail = @"送货上门";
    request.shippingMethods = @[methods,methods1];
    
    //配置快递类型
    request.shippingType = PKShippingTypeStorePickup;
    //添加附加数据
    request.applicationData = [@"gouwuche=123" dataUsingEncoding:NSUTF8StringEncoding];
    
    //验证用户的支付授权
    PKPaymentAuthorizationViewController * avc = [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:request];
    avc.delegate = self;
    [self presentViewController:avc animated:YES completion:nil];
}


/**
 *  当用户授权成功后 会调用此方法
 *
 *  @param controller 授权的控制器
 *  @param payment    支付对象
 *  @param completion 系统给定的一个回调代码块,我们需要执行这个代码块,来告诉系统当前的支付状态是否成功
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion{
    //一般在此处拿到支付信息.发送给服务器,处理完毕之后,服务器会返回一个状态,告诉客户端,是否支付成功,然后由客户端进行操作
    BOOL isSucc = YES;
    if (isSucc) {
        completion(PKPaymentAuthorizationStatusSuccess);
    }else{
         completion(PKPaymentAuthorizationStatusFailure);
    }
    
}


/**
 *  当用户授权成功或者取消授权时调用
 *
 *  @param controller <#controller description#>
 */
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    NSLog(@"授权结束");
    [self dismissViewControllerAnimated:controller completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
