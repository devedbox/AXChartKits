Pod::Spec.new do |s|

  s.name         = "AXChartKits"
  s.version      = "0.1.0"
  s.summary      = "A chart manager kits."
  s.description  = <<-DESC
                    A chart manager kits using on iOS platform.
                   DESC

  s.homepage     = "https://github.com/devedbox/AXChartKits"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "aiXing" => "862099730@qq.com" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/devedbox/AXChartKits.git", :tag => "0.1.0" }
  s.source_files  = "AXChartKits/AXChartKits/*.{h,m}"

  s.frameworks = "UIKit", "CoreGraphics", "Foundation"

  s.requires_arc = true
  s.dependency "pop", "~> 1.0.8"

end
