//
//  FGAddressBookTool.m
//  FGAddressBook
//
//  Created by xia on 18/9/14.
//  Copyright © 2016年 HuaZhongShiXun. All rights reserved.
//

#import "FGAddressBookTool.h"

@implementation FGAddressBookTool

+ (UIAlertController *)showAletr:(NSString *)title
                             msg:(NSString *)msg
                       leftTitle:(NSString *)left
                      leftAction:(void (^)(void))leftAction
                           right:(NSString *)right
                     rightAction:(void (^)(void))rightAction {
    __weak typeof(self) wkself = self;
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    if(left) {
        UIAlertAction *leftBtn = [UIAlertAction actionWithTitle:left
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
            if(leftAction) {
                leftAction();
            }
            [wkself dissmis:alert];
        }];
        [alert addAction:leftBtn];
    }
    if(right) {
        UIAlertAction *rightBtn = [UIAlertAction actionWithTitle:right
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
            if(rightAction) {
                rightAction();
            }
            [wkself dissmis:alert];
        }];
        [alert addAction:rightBtn];
    }
   [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                animated:YES
                                                                              completion:nil];
    return alert;
}
+ (void)dissmis:(UIAlertController *)sender {
    [sender dismissViewControllerAnimated:YES completion:nil];
}

+ (BOOL)isAlphabet:(unichar)c {
    BOOL captional = (c >= 65 && c <= 90);
    BOOL little = (c >= 97 && c <= 122);
    return (captional || little);
}

+ (BOOL)isPhoneNumber:(NSString *)phoneNumber {
    NSString *reg=@"^1[3456789]([0-9]){9}$";
    NSPredicate *mobliePredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",reg];
    BOOL result=[mobliePredicate evaluateWithObject:phoneNumber];
    return result;
}

+ (void)asyncInGlobalQueue:(void (^)(void))task {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(task){
            task();
        }
    });
}
+ (void)asyncInMainQueue:(void (^)(void))task {
    if (task==nil) {
        return;
    }
    if ([NSThread isMainThread]) {
        task();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            task();
        });
    }
}

+ (void)detachNewConcurrentQueueWithIdentifier:(const char *)idtentifer task:(void (^)(void))task {
    dispatch_queue_t queue=dispatch_queue_create(idtentifer, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        if (task) {
            task();
        }
    });
}

@end
