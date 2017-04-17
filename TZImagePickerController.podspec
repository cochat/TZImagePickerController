Pod::Spec.new do |s|
  s.name         = "RHImagePickerController"
  s.version      = "1.7.9.0.1"
  s.summary      = "A clone of UIImagePickerController, support picking multiple photos、original photo and video"
  s.homepage     = "https://github.com/cochat/TZImagePickerController"
  s.license      = "MIT"
  s.author       = { "banchichen" => "tanzhenios@foxmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/cochat/TZImagePickerController.git", :tag => s.version.to_s}
  s.requires_arc = true
  s.resources    = "TZImagePickerController/TZImagePickerController/*.{png,xib,nib,bundle}"
  s.source_files = "TZImagePickerController/TZImagePickerController/*.{h,m}"
end
