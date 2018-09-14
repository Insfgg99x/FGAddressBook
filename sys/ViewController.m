//
//  ViewController.m
//  FGAddressbook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 xgf. All rights reserved.
//

#import "ViewController.h"
#import "FGAddressBook.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UITableView *table;
@property(nonatomic, strong)NSMutableArray *addressBookArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self createUI];
    [self loadAddressBook];
}
- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];
    _addressBookArray = [NSMutableArray array];
}

- (void)createUI {
    _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = [UIView new];
    if(@available(iOS 11, *)) {
        _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_table];
}

- (void)loadAddressBook {
    __weak  typeof(self) wkself = self;
    [FGAddressBook shared].didAddNewItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
        NSLog(@"新增了这些联系人：\n%@",items);
    };
    [FGAddressBook shared].didDeleteItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
        NSLog(@"删除了这些联系人：\n%@",items);
    };
    [FGAddressBook shared].didChangeItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
        @synchronized(wkself.addressBookArray) {
            [wkself.addressBookArray setArray:items];
        }
        [wkself.table reloadData];
    };
    [[FGAddressBook shared] authAddressBook:^(BOOL granted) {
        if(!granted) {
            return;
        }
        [[FGAddressBook shared] loadAddressbook:^(NSArray<FGAddressBookModel *> *items) {
            @synchronized(wkself.addressBookArray) {
                [wkself.addressBookArray setArray:items];
            }
            [wkself.table reloadData];
        }];
    }];
}

//MARK: - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressBookArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cid"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cid"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    FGAddressBookModel *m = self.addressBookArray[indexPath.row];
    cell.textLabel.text = m.name;
    cell.detailTextLabel.text = m.phone;
    cell.imageView.image = m.thumbnailImage;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FGAddressBookModel *m = self.addressBookArray[indexPath.row];
    NSString *phone = m.phone;
    NSString *name = m.name;
    [FGAddressBookTool showAlert:[NSString stringWithFormat:@"拨打电话给%@吗",name]
                             msg:phone
                       leftTitle:@"取消"
                      leftAction:^{
                          
                      } right:@"拨打"
                     rightAction:^{
                         [self call:phone];
                     }];
}
- (void)call:(NSString *)phone {
    NSString *tel = [NSString stringWithFormat:@"tel://%@",phone];
    NSURL *url = [NSURL URLWithString:tel];
    if(![[UIApplication sharedApplication] canOpenURL:url]) {
        return;
    }
    [[UIApplication sharedApplication] canOpenURL:url];
}

@end
