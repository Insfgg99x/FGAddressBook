//
//  FGAddressBookTool.h
//  FGAddressBook
//
//  Created by xia on 18/9/14.
//  Copyright © 2016年 HuaZhongShiXun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FGAddressBookTool : NSObject

/**
 *  显示警告视图
 *
 *  @param title       标题
 *  @param msg         信息
 *  @param left        左侧按钮标题
 *  @param leftAction   左侧按钮动作
 *  @param right       右侧按钮标题
 *  @param rightAction 右侧按钮动作
 */
+(UIAlertController *)showAlert:(NSString *)title
                            msg:(NSString *)msg
                      leftTitle:(NSString *)left
                     leftAction:(void(^)(void))leftAction
                          right:(NSString *)right
                    rightAction:(void (^)(void))rightAction;

/* *
 * 是不是字母
 */
+ (BOOL)isAlphabet:(unichar)c;

+ (BOOL)isPhoneNumber:(NSString *)phoneNumber;

+ (void)asyncInGlobalQueue:(void (^)(void))task;

+ (void)asyncInMainQueue:(void (^)(void))task;

+ (void)detachNewConcurrentQueueWithIdentifier:(const char *)idtentifer task:(void (^)(void))task;

@end
