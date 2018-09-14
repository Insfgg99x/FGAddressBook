//
//  FGAddressBook.h
//  FGAddressBook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 HuaZhongShiXun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGAddressBookModel.h"
#import "FGAddressBookTool.h"

typedef void(^FGAddressBookChangeHandler) (NSArray<FGAddressBookModel *> *items);

@interface FGAddressBook : NSObject

/**通讯录改变了*/
@property(nonatomic, copy)FGAddressBookChangeHandler didChangeItemsHandler;
/**通讯录新增了联系人*/
@property(nonatomic, copy)FGAddressBookChangeHandler didAddNewItemsHandler;
/**通讯录删除了联系人*/
@property(nonatomic, copy)FGAddressBookChangeHandler didDeleteItemsHandler;

+ (instancetype)shared;

- (void)authAddressBook:(void(^)(BOOL granted))completion;

- (void)loadAddressbook:(void(^)(NSArray<FGAddressBookModel *> *items))completion;

@end
