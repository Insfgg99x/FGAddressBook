Pod::Spec.new do |s|

s.name         = "FGAddressBook"
s.version      = "1.0"
s.summary      = "FGAddressBook便捷的手机通讯录联系人工具，获取联系人列表，监听并后去通讯录的变化"
s.homepage     = "https://github.com/Insfgg99x/FGAddressBook"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/FGAddressBook.git", :tag => "1.0" }
s.frameworks   = 'Foundation','UIKit', 'Contacts'
s.platform     = :ios, '6.0'
s.source_files = 'FGAddressBook/*.{h,m}'
s.requires_arc = true
#s.dependency 'SDWebImage

end

