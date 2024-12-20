#
#  Be sure to run `pod spec lint TQLNest.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "TQPDFReader"
  s.version      = "0.0.11"
  s.summary      = "pdf 阅读器."
  s.homepage     = "https://github.com/TianQiLi/TQPDFReader"
  s.license      = "MIT"
  s.author       = { "litianqi" => "871651575@qq.com" }
  s.platform     = :ios, "11.0"
s.frameworks = "UIKit", "Foundation" , "CoreGraphics"
s.source       = { :git => "https://github.com/EragonTQ/TQPDFReader.git", :tag => "#{s.version}" }
  s.source_files  = "TQPDFReader/**/*.{h,m}"

  s.resources = "TQPDFReader/PDFReaderXib/*.storyboard","TQPDFReader/Resources/*.bundle"
  s.requires_arc = true
  s.dependency "SVProgressHUD"
 # s.dependency "CocoaLumberjack"
  s.dependency "Masonry"
  s.dependency "FDFullscreenPopGesture"
 end
