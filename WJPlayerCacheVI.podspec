Pod::Spec.new do |s|

s.name         = "WJPlayerCacheVI"
s.version      = "1.0"
s.summary      = "播放器媒体缓存."

s.description  = <<-DESC
    基于VIMediaCache实现的WJPlayer缓存
DESC

s.homepage     = "https://github.com/yunhaiwu"

s.license      = { :type => "MIT", :file => "LICENSE" }

s.author             = { "吴云海" => "halayun@qq.com" }

s.platform     = :ios, "7.0"

s.source       = { :git => "https://github.com/yunhaiwu/ios-wj-player-cache-vi.git", :tag => "#{s.version}" }

s.exclude_files = "Example"

s.source_files = 'Classes/*.{h,m}'
s.public_header_files = 'Classes/*.h'

s.requires_arc = true

s.frameworks = "Foundation", "UIKit", "AVFoundation"

s.dependency "WJLoggingAPI"
s.dependency "WJPlayerKit", '>=1.0'
s.dependency "VIMediaCache", '0.4'
s.dependency "WJConfig", '>=2.0'

end
