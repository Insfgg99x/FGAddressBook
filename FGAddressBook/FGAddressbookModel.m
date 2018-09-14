
//
//  FGAddressBookModel.m
//  FGAddressBook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 HuaZhongShiXun. All rights reserved.
//

#import "FGAddressBookModel.h"
#import "NSString+Chinese.h"
#import "FGAddressBookTool.h"

@implementation FGAddressBookModel

//MARK: - Contactable
- (NSComparisonResult)sort:(FGAddressBookModel *)other {
    NSString *p1 = self.name.pinyin;
    NSString *p2 = other.name.pinyin;
    if(p1.length > 0 && p2.length > 0) {
        unichar c1 = [p1 characterAtIndex:0];
        unichar c2 = [p2 characterAtIndex:0];
        if([FGAddressBookTool isAlphabet:c1] && [FGAddressBookTool isAlphabet:c2]) {
            NSString *t1 = [[p1 substringToIndex:1] uppercaseString];
            NSString *t2 = [[p2 substringToIndex:1] uppercaseString];
            return [t1 compare:t2];
        } else if([FGAddressBookTool isAlphabet:c1]) {
            return NSOrderedAscending;
        } else if([FGAddressBookTool isAlphabet:c2]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    } else {
        return NSOrderedDescending;
    }
}

@end
