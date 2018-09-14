//
//  FGAddressBookModel.h
//  FreeChat
//
//  Created by xgf on 2018/9/12.
//  Copyright © 2018年 HuaZhongShiXun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGAddressBookModel : NSObject

@property(nonatomic,copy)NSString *phone;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *headimg;

- (NSComparisonResult)sort:(FGAddressBookModel *)other;

@end
