//
//  ViewController.m
//  FGAddressbook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 xgf. All rights reserved.
//

#import "ViewController.h"
#import "FGAddressBook.h"
#import "FGAddressBookTool.h"
#import "AddressBookCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UITableView *table;
@property(nonatomic, strong)NSMutableArray *addressBookArray;
@property(nonatomic, strong)NSMutableArray *indexArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self createUI];
    [self loadAddressBook];
}
- (void)setup {
    self.title = @"FGAddressBook";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    _addressBookArray = [NSMutableArray array];
    _indexArray = [NSMutableArray array];
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
//MARK: - load data
- (void)loadAddressBook {
    __weak  typeof(self) wkself = self;
    [FGAddressBook shared].didAddNewItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
        NSLog(@"新增了这些联系人：\n%@",items);
    };
    [FGAddressBook shared].didDeleteItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
        NSLog(@"删除了这些联系人：\n%@",items);
    };
    [FGAddressBook shared].didChangeItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
        [wkself refreshWithItems:items];
    };
    [[FGAddressBook shared] authAddressBook:^(BOOL granted) {
        if(!granted) {
            return;
        }
        [[FGAddressBook shared] loadAddressbook:^(NSArray<FGAddressBookModel *> *items) {
            [wkself refreshWithItems:items];
        }];
    }];
}

- (void)refreshWithItems:(NSArray<FGAddressBookModel *> *)items {
    [self groupUp:items];
    [self fetchIndexes];
    [self.table reloadData];
}

//MARK: - 分组
- (void)groupUp:(NSArray *)sourceArray {
    NSMutableArray *sortedArray = [NSMutableArray array];
    @synchronized(sourceArray) {
        sourceArray = [sourceArray sortedArrayUsingSelector:@selector(sort:)];
        for(int i = 0; i < sourceArray.count;) {
            NSMutableArray *sectionArray = [NSMutableArray array];
            FGAddressBookModel *u = sourceArray[i];
            [sectionArray addObject:u];
            for(int j = i+1; j < sourceArray.count; j++) {
                FGAddressBookModel *v = sourceArray[j];
                NSString *c1 = [NSString getFirstLetter:u.name];
                NSString *c2 = [NSString getFirstLetter:v.name];
                if(c1.length > 0 && c2.length > 0) {
                    c1 = [c1 substringToIndex:1];
                    c2 = [c2 substringToIndex:1];
                    if([FGAddressBookTool isAlphabet:[c1 characterAtIndex:0]]) {
                        if([c1 isEqualToString:c2]) {
                            [sectionArray addObject:v];
                            continue;
                        } else {
                            break;
                        }
                    } else {
                        if(![FGAddressBookTool isAlphabet:[c2 characterAtIndex:0]]) {
                            [sectionArray addObject:v];
                            continue;
                        } else {
                            break;
                        }
                    }
                } else {
                    if(c1.length == 0) {
                        if(c2.length == 0) {
                            [sectionArray addObject:v];
                            continue;
                        } else {
                            if(![FGAddressBookTool isAlphabet:[c2 characterAtIndex:0]]) {
                                [sectionArray addObject:v];
                                continue;
                            } else {
                                break;
                            }
                        }
                    } else {
                        if([FGAddressBookTool isAlphabet:[c1 characterAtIndex:0]]) {
                            break;
                        } else {
                            [sectionArray addObject:v];
                            continue;
                        }
                    }
                }
            }
            i += sectionArray.count;
            [sortedArray addObject:sectionArray];
        }
    }
    @synchronized(self.addressBookArray) {
        [self.addressBookArray setArray:sortedArray];
    }
}
//MARK: - 提取索引
- (void)fetchIndexes {
    NSMutableArray *indexes = [NSMutableArray array];
    for(NSArray *array in self.addressBookArray) {
        FGAddressBookModel *m = array.firstObject;
        NSString *py = m.name.pinyin;
        if(py.length > 1) {
            if([FGAddressBookTool isAlphabet:[py characterAtIndex:0]]) {
                NSString *first = [[py substringToIndex:1] uppercaseString];
                [indexes addObject:first];
            } else {
                [indexes addObject:@"#"];
            }
        } else {
            [indexes addObject:@"#"];
        }
    }
    @synchronized(self.indexArray) {
        [self.indexArray setArray:indexes];
    }
}
//MARK: - call
- (void)call:(NSString *)phone {
    NSString *tel = [NSString stringWithFormat:@"tel://%@",phone];
    NSURL *url = [NSURL URLWithString:tel];
    if(![[UIApplication sharedApplication] canOpenURL:url]) {
        return;
    }
    [[UIApplication sharedApplication] canOpenURL:url];
}
//MARK: - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.addressBookArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addressBookArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cid"];
    if(!cell) {
        cell = [[AddressBookCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cid"];
    }
    FGAddressBookModel *m = self.addressBookArray[indexPath.section][indexPath.row];
    [cell bind:m];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    header.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 50, 20)];
    lb.text = self.indexArray[section];
    lb.font = [UIFont boldSystemFontOfSize:18];
    lb.textColor = [UIColor darkGrayColor];
    [header addSubview:lb];
    return header;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArray;
}

@end
