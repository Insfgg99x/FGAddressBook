
//
//  AddressBookCell.m
//  FGAddressbook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 xgf. All rights reserved.
//

#import "AddressBookCell.h"
#import <Masonry/Masonry.h>

@interface AddressBookCell()

@property(nonatomic, strong)UILabel *nameLb;
@property(nonatomic, strong)UILabel *phoneLb;
@property(nonatomic, strong)UIImageView *head;

@end

@implementation AddressBookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        [self createUI];
    }
    return self;
}

-(void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)createUI {
    _head = [[UIImageView alloc] init];
    _head.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_head];
    [_head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@40);
        make.width.equalTo(@0);
    }];
    
    _nameLb = [[UILabel alloc] init];
    _nameLb.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_nameLb];
    [_nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.head.mas_right).offset(10);
        make.top.equalTo(self.head);
        make.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    _phoneLb = [[UILabel alloc] init];
    _phoneLb.font = [UIFont systemFontOfSize:12];
    _phoneLb.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_phoneLb];
    [_phoneLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLb.mas_bottom).offset(5);
        make.height.equalTo(@15);
        make.left.right.equalTo(self.nameLb);
    }];
}

- (void)bind:(FGAddressBookModel *)model {
    _nameLb.text = model.name;
    _phoneLb.text = model.phone;
    _head.image = model.thumbnailImage;
    if(model.thumbnailImage) {
        [_head mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@40);
        }];
        [_nameLb mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.head.mas_right).offset(10);
        }];
    } else {
        [_head mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        [_nameLb mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.head.mas_right);
        }];
    }
}

@end
