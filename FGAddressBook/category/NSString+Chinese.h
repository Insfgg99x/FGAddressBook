
#import <Foundation/Foundation.h>

@interface NSString (Chinese)

@property(nonatomic,copy,readonly)NSString *pinyin;
@property(nonatomic,copy,readonly)NSString *letters;

- (BOOL)includeChinese;//判断是否含有汉字
- (BOOL)isChinese;
+ (NSString *)getFirstLetter:(NSString *)chinese;

@end
