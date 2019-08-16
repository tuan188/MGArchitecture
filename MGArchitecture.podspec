Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "MGArchitecture"
s.summary = "Clean Architecture with RxSwift and MVVM"
s.requires_arc = true

# 2
s.version = "1.0.1"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Tuan Truong" => "tuan188@gmail.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/tuan188/MGArchitecture"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/tuan188/MGArchitecture.git",
:tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'RxSwift', '~> 5.0'
s.dependency 'RxCocoa', '~> 5.0'

# 8
s.source_files = "MGArchitecture/Sources/**/*.{swift}"

# 9
# s.resources = "MGArchitecture/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end

