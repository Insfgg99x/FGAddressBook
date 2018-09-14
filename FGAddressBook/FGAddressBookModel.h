//
//  FGAddressBookModel.h
//  FreeChat
//
//  Created by xgf on 2018/9/12.
//  Copyright © 2018年 HuaZhongShiXun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FGAddressBookModel : NSObject

@property(nonatomic, copy)NSString *phone;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, strong)NSData *imageData;
@property(nonatomic, strong)UIImage *image;
@property(nonatomic, strong)NSData *thumbnailImageData;
@property(nonatomic, strong)UIImage *thumbnailImage;


- (NSComparisonResult)sort:(FGAddressBookModel *)other;

@end
