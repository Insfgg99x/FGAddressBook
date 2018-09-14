# FGAddressBook

--------------------

获取手机通讯录联系人列表（兼容iOS 8以下设备），监听通讯录的变化，获取这些变化。

[](/src/demo.png)

## 使用

- 手机通讯录改变（新增、删除）的回调

```swift
[FGAddressBook shared].didAddNewItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
    NSLog(@"新增了这些联系人：\n%@",items);
};
[FGAddressBook shared].didDeleteItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
    NSLog(@"删除了这些联系人：\n%@",items);
};
```

- 通讯录变化的回调（直接回调最新的通讯录列表）

```swift
[FGAddressBook shared].didChangeItemsHandler = ^(NSArray<FGAddressBookModel *> *items) {
    @synchronized(wkself.addressBookArray) {
        [wkself.addressBookArray setArray:items];
    }
    [wkself.table reloadData];
};
```

- 获取通讯录联系人列表

```
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
```
## 安装

```swift
pod repo update
pod 'FGAddressBook'
```

--------------------------
@end