Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "MGArchitecture"
s.summary = "Clean Architecture with RxSwift and MVVM"
s.requires_arc = true

# 2
s.version = "0.4.0"

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
s.dependency 'RxAtomic', '~> 4.4'
s.dependency 'RxSwift', '~> 4.4'
s.dependency 'RxCocoa', '~> 4.4'

# 8
s.subspec 'Extensions' do |ss|
    ss.source_files = "MGArchitecture/Sources/Extensions/*.{swift}"
end

s.subspec 'Model' do |ss|
    ss.source_files = "MGArchitecture/Sources/Model/*.{swift}"
end

s.subspec 'View' do |ss|
    ss.source_files = "MGArchitecture/Sources/View/*.{swift}"
end

s.subspec 'ViewModel' do |ss|
    ss.source_files = "MGArchitecture/Sources/ViewModel/*.{swift}"
end

# 9
# s.resources = "MGArchitecture/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end

