//
//  FGAddressBook.m
//  FGAddressBook
//
//  Created by xgf on 2018/9/14.
//  Copyright © 2018年 HuaZhongShiXun. All rights reserved.
//

#import "FGAddressBook.h"
#import "FGAddressBookTool.h"
#ifdef __IPHONE_9_0
    #import <Contacts/Contacts.h>
#endif
#import <AddressBook/AddressBook.h>

static FGAddressBook *addressbook = nil;

@interface FGAddressBook ()

@property(nonatomic, strong)NSMutableArray *addressbookItems;
#ifdef __IPHONE_9_0
@property(nonatomic, strong)CNContactStore *store;
#endif

@end

@implementation FGAddressBook

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addressbook = [FGAddressBook new];
    });
    return addressbook;
}
- (instancetype)init {
    if(self = [super init]) {
        _addressbookItems = [NSMutableArray array];
        _store = [CNContactStore new];
        [self monitorChange];
    }
    return self;
}
- (void)monitorChange {
    if (@available(iOS 9, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactDidChange:)
                                                     name:CNContactStoreDidChangeNotification
                                                   object:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ABAddressBookRef addresBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(addresBook, addressbookChangeHandler, (__bridge void *)(self));
#pragma clang diagnostic pop
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
void addressbookChangeHandler(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    [[FGAddressBook shared] reloadChange];
}
#pragma clang diagnostic pop
- (void)contactDidChange:(NSNotification *)sender {
    [self reloadChange];
}
- (void)reloadChange {
    __weak typeof(self) wkself = self;
    [self fetchContact:^(NSArray<FGAddressBookModel *> *items) {
        NSArray<FGAddressBookModel *> *a1 = [FGAddressBook minuSet:items and:wkself.addressbookItems];
        NSArray<FGAddressBookModel *> *a2 = [FGAddressBook minuSet:wkself.addressbookItems and:items];
        [wkself.addressbookItems setArray:items];
        if(wkself.didChangeItemsHandler) {
            wkself.didChangeItemsHandler(items);
        }
        if(a1.count > 0) {
            if(wkself.didAddNewItemsHandler) {
                wkself.didAddNewItemsHandler(a1);
            }
        }
        if(a2.count > 0) {
            if(wkself.didDeleteItemsHandler) {
                wkself.didDeleteItemsHandler(a2);
            }
        }
    }];
}
+ (NSArray<FGAddressBookModel *> *)minuSet:(NSArray<FGAddressBookModel *> *)s1 and:(NSArray<FGAddressBookModel *> *)s2 {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF.phone in %@.phone)", s2];
    NSArray<FGAddressBookModel *> *result = [s1 filteredArrayUsingPredicate:predicate];
    return result;
}
//MARK: - auth
- (void)authAddressBook:(void(^)(BOOL granted))completion {
    if (@available(iOS 9, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if(status == CNAuthorizationStatusNotDetermined) {
            [FGAddressBookTool showAlert:@"开启通讯录权限"
                             msg:@"首次启动需要开启通讯录权限"
                       leftTitle:@"取消"
                      leftAction:^{
                          
                      } right:@"开启"
                     rightAction:^{
                         [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
                             if(completion) {
                                 completion(granted);
                             }
                         }];
                     }];
        } else {
            [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
                if(completion) {
                    completion(granted);
                }
            }];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if(status == kABAuthorizationStatusNotDetermined) {
            [FGAddressBookTool showAlert:@"开启通讯录权限"
                             msg:@"首次启动需要开启通讯录权限"
                       leftTitle:@"取消"
                      leftAction:^{
                          
                      } right:@"开启"
                     rightAction:^{
                         ABAddressBookRef adressbookRef = ABAddressBookCreate();
                         ABAddressBookRequestAccessWithCompletion(adressbookRef, ^(bool granted, CFErrorRef error) {
                             if(completion) {
                                 completion(granted);
                             }
                         });
                         //CFRelease(adressbookRef); ios 8.1上会崩溃
                     }];
        } else {
            ABAddressBookRef adressbookRef = ABAddressBookCreate();
            ABAddressBookRequestAccessWithCompletion(adressbookRef, ^(bool granted, CFErrorRef error) {
                if(completion) {
                    completion(granted);
                }
            });
        }
#pragma clang diagnostic pop
    }
}
- (void)loadAddressbook:(void(^)(NSArray<FGAddressBookModel *> *items))completion {
    __weak typeof(self) wkself = self;
    [self fetchContact:^(NSArray<FGAddressBookModel *> *items) {
        @synchronized(wkself.addressbookItems) {
            [wkself.addressbookItems setArray:items];
        }
        if(completion) {
            completion(items);
        }
    }];
}
- (void)fetchContact:(void(^)(NSArray<FGAddressBookModel *> *items))completion {
    [FGAddressBookTool detachNewConcurrentQueueWithIdentifier:"addressbook" task:^{
        if (@available(iOS 9, *)) {
            [self fetchByCNContact:completion];
        } else {
            [self fetchByABAddresBook:completion];
        }
    }];
}
- (void)fetchByCNContact: (void(^)(NSArray<FGAddressBookModel *> *items))completion {
    NSMutableArray<FGAddressBookModel *> *array = [NSMutableArray<FGAddressBookModel *> array];
    NSArray *propertys = @[CNContactGivenNameKey,
                           CNContactFamilyNameKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataKey,
                           CNContactThumbnailImageDataKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:propertys];
    [self.store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
        NSString *firstName = contact.familyName;
        NSString *givenName = contact.givenName;
        NSString *fullName = [NSString stringWithFormat:@"%@%@",firstName,givenName];
        UIImage *image = [[UIImage alloc] initWithData:contact.imageData];
        UIImage *thumbnailImage = [[UIImage alloc] initWithData:contact.thumbnailImageData];
        NSArray *phones = contact.phoneNumbers;
        for(CNLabeledValue *tag in phones) {
            CNPhoneNumber *number = tag.value;
            NSString *phone = number.stringValue;
            if(phone != nil) {
                phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];//无法移除系统自己在phone中生成的空白（用第一句可以移除）
                if([FGAddressBookTool isPhoneNumber:phone]) {
                    FGAddressBookModel *model = [[FGAddressBookModel alloc] init];
                    model.name = fullName;
                    model.phone = phone;
                    model.imageData = contact.imageData;
                    model.image = image;
                    model.thumbnailImageData = contact.thumbnailImageData;
                    model.thumbnailImage = thumbnailImage;
                    [array addObject:model];
                }
            }
        }
    }];
    if(completion) {
        [FGAddressBookTool asyncInMainQueue:^{
            completion(array);
        }];
    }
}
- (void)fetchByABAddresBook: (void(^)(NSArray<FGAddressBookModel *> *items))completion {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSMutableArray<FGAddressBookModel *> *array = [NSMutableArray<FGAddressBookModel *> array];
    ABAddressBookRef adressbookRef = ABAddressBookCreate();
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(adressbookRef);
    NSInteger count = CFArrayGetCount(arrayRef);
    for(NSInteger i = 0; i < count; i++) {
        ABRecordRef recordRef = CFArrayGetValueAtIndex(arrayRef, i);
        CFStringRef first = ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
        CFStringRef last = ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
        NSString *firstName = (__bridge NSString *)first;
        NSString *lastName = (__bridge NSString *)last;
        if (!firstName) {
            firstName = @"";
        }
        if (!lastName) {
            lastName = @"";
        }
        NSString *name = [NSString stringWithFormat:@"%@%@",firstName,lastName];
        NSData *imageData = (__bridge NSData *)ABRecordCopyValue(recordRef, kABPersonImageFormatThumbnail);
        NSData *thumbnailImageData = (__bridge NSData *)ABRecordCopyValue(recordRef, kABPersonImageFormatOriginalSize);
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        UIImage *thumbnailImage = [[UIImage alloc] initWithData:thumbnailImageData];
        ABMultiValueRef phonesRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
        NSInteger phoneCount = ABMultiValueGetCount(phonesRef);
        for(int j = 0; j < phoneCount; j++) {
            CFStringRef noRef = ABMultiValueCopyValueAtIndex(phonesRef, j);
            NSString *phone = (__bridge NSString *)noRef;
            if(phone != nil) {
                phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
                phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];//无法移除系统自己在phone中生成的空白（用第一句可以移除）
                if([FGAddressBookTool isPhoneNumber:phone]) {
                    FGAddressBookModel *model = [[FGAddressBookModel alloc] init];
                    model.name = name;
                    model.phone = phone;
                    model.imageData = imageData;
                    model.image = image;
                    model.thumbnailImageData = thumbnailImageData;
                    model.thumbnailImage = thumbnailImage;
                    [array addObject:model];
                }
            }
            CFRelease(noRef);
        }
        CFRelease(phonesRef);
    }
    CFRelease(adressbookRef);
    CFRelease(arrayRef);
#pragma clang diagnostic pop
    if(completion) {
        [FGAddressBookTool asyncInMainQueue:^{
            completion(array);
        }];
    }
}

@end
