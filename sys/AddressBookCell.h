//
//  AddressBookCell.h
//  FGAddressbook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 xgf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGAddressBookModel.h"

@interface AddressBookCell : UITableViewCell

- (void)bind:(FGAddressBookModel *)model;

@end
