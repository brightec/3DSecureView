Pod::Spec.new do |s|

  s.name         = "ThreeDSecureView"
  s.version      = "1.0.0"
  s.summary      = "ThreeDSecureView allows you to handle the 3DSecure payment process in your iOS app."
  s.description  = <<-DESC
  ThreeDSecureView is primarily a WKWebView that handles the 3DSecure payment process by sending a POST request to the provided
  card issuer URL with the MD and PaReq parameters set. The WKWebView then intercepts the POST response from the card issuer,
  extracts the MD and PaRes values and passes them back to your app.
                   DESC

  s.homepage     = "https://github.com/brightec/3DSecureView"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "Chris Leversuch" => "chris@brightec.co.uk" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/brightec/3DSecureView.git", :tag => "#{s.version}" }
  s.source_files  = "Source"
  s.requires_arc = true
  s.swift_version = "4.0"

end
